const fs = require('fs');
const express = require('express');
const Database = require('better-sqlite3');

const db = new Database(process.env.DB_PATH || 'run_ride.db');
db.pragma('foreign_keys = ON'); // SQLite does not enforce foreign keys unless asked

const app = express();
app.use(express.json());
app.use(express.static('public'));

// Errors we want to show the user as a normal message.
class UserError extends Error {
  constructor(message, status = 400) { super(message); this.status = status; }
}

// The SQL lives only in queries.sql. Each "-- Requirement N:" block becomes
// GET /api/queries/N, returning that query's rows.
// queries ends up as an array of 9 objects like the following
// {
//     id: 1
//     title: 'Filtering and Sorting'
//     description: 'Which long rides .....
//     statment: <prepared SQL statment for the SELECT>
// }
const queries = fs.readFileSync('queries.sql', 'utf8')
  .split(/^-- Requirement (?=\d+:)/m).slice(1)
  .map((block) => {
    const lines = block.split('\n');
    const comments = lines.filter((l) => l.startsWith('--')).map((l) => l.slice(2).trim());
    const sql = lines.slice(1).filter((l) => !l.startsWith('--')).join('\n').trim();
    return {
      id: parseInt(block, 10),
      //               removes the 1:                removes trailing note  trim removes leftover spaces
      title: lines[0].replace(/^\d+:\s*/, '').replace(/\s*\(.*\)\s*$/, '').trim(), // drop the "(supports ...)" note
      // joins comment lines into one sentence (string)
      description: comments.join(' '),
      // asks SQLite to compile a SQL once and keep the compiled statement
      statement: db.prepare(sql),
    };
  });

app.get('/api/queries', (req, res) => {
  res.json(queries.map(({ id, title, description }) => ({ id, title, description })));
});

app.get('/api/queries/:id', (req, res) => {
  console.log('SQLite queuery: ' + req.params.id + ' called.');
  const q = queries.find((x) => x.id === Number(req.params.id));
  if (!q) throw new UserError('No such query', 404);
  res.json(q.statement.all());
});

app.get('/api/athletes', (req, res) => {
  console.log('Athletes endpoint called.');
  res.json(db.prepare('SELECT athlete_id, first_name || \' \' || last_name AS name, preferred_units FROM athlete').all());
});

app.get('/api/gear', (req, res) => {
  console.log('Gear endpoint called.');
  res.json(db.prepare(
    `SELECT gear_id, name, gear_type, is_retired FROM gear
     WHERE athlete_id = ? ORDER BY is_retired, name`).all(req.query.athlete_id));
});

app.get('/api/devices', (req, res) => {
  console.log('Devices endpoint called.');
  res.json(db.prepare('SELECT device_id, device_name FROM device WHERE athlete_id = ?').all(req.query.athlete_id));
});

app.get('/api/events', (req, res) => {
  console.log('Events endpoint called.');
  res.json(db.prepare('SELECT event_id, name, sport, event_date FROM event ORDER BY event_date').all());
});

app.get('/api/activities', (req, res) => {
  console.log('Activities endpoint called.');
  const { sport, athlete_id } = req.query;
  res.json(db.prepare(
    `SELECT ac.activity_id, a.first_name || ' ' || a.last_name AS athlete, ac.sport, ac.start_time,
            ROUND(ac.distance_m / 1000.0, 1) AS distance_km, ROUND(ac.duration_sec / 60.0, 1) AS duration_min,
            ac.avg_hr, g.name AS gear, d.device_name AS device, ac.notes
     FROM activity ac
     JOIN athlete a      ON a.athlete_id = ac.athlete_id
     LEFT JOIN gear g    ON g.gear_id    = ac.gear_id
     LEFT JOIN device d  ON d.device_id  = ac.device_id
     WHERE (? IS NULL OR ac.sport = ?) AND (? IS NULL OR ac.athlete_id = ?)
     ORDER BY ac.start_time DESC`
  ).all(sport || null, sport || null, athlete_id || null, athlete_id || null));
});


// Add an activity

const GEAR_FOR = { cycling: 'bike', running: 'shoes' };

// Throws an error unless the gear/device belong to the athlete and gear matches the sport.
function checkGearAndDevice(athleteId, sport, gearId, deviceId) {
  if (gearId) {
    const g = db.prepare('SELECT athlete_id, gear_type FROM gear WHERE gear_id = ?').get(gearId);
    if (!g || g.athlete_id !== athleteId) throw new UserError('That gear does not belong to this athlete');
    if (g.gear_type !== GEAR_FOR[sport]) throw new UserError(`${sport} activities need ${GEAR_FOR[sport]} gear`);
  }
  if (deviceId) {
    const d = db.prepare('SELECT athlete_id FROM device WHERE device_id = ?').get(deviceId);
    if (!d || d.athlete_id !== athleteId) throw new UserError('That device does not belong to this athlete');
  }
}

// Turns the form fields (km, minutes) into the values stored in the table (meters, seconds).
function cleanActivity(b) {
  const athleteId = Number(b.athlete_id);
  const distanceKm = Number(b.distance_km);
  const durationMin = Number(b.duration_min);
  if (!Number.isInteger(athleteId) || athleteId < 1) throw new UserError('Choose an athlete');
  if (!GEAR_FOR[b.sport]) throw new UserError('Sport must be cycling or running');
  if (!b.start_time || Number.isNaN(Date.parse(b.start_time))) throw new UserError('Enter a valid start date and time');
  if (!(distanceKm > 0)) throw new UserError('Distance must be greater than 0');
  if (!(durationMin > 0)) throw new UserError('Duration must be greater than 0');
  const avgHr = b.avg_hr ? Number(b.avg_hr) : null;
  if (avgHr !== null && !(avgHr > 0 && avgHr < 250)) throw new UserError('Average heart rate must be between 1 and 249');

  const gearId = b.gear_id ? Number(b.gear_id) : null;
  const deviceId = b.device_id ? Number(b.device_id) : null;
  checkGearAndDevice(athleteId, b.sport, gearId, deviceId);

  const distanceM = distanceKm * 1000;
  const durationSec = Math.round(durationMin * 60);
  return {
    athlete_id: athleteId, gear_id: gearId, device_id: deviceId, sport: b.sport,
    start_time: new Date(b.start_time + (b.start_time.endsWith('Z') ? '' : 'Z')).toISOString().replace('.000Z', 'Z'),
    duration_sec: durationSec, distance_m: distanceM, avg_speed_mps: distanceM / durationSec,
    avg_hr: avgHr, notes: (b.notes || '').trim() || null,
  };
}

const insertActivity = db.prepare(
  `INSERT INTO activity (athlete_id, gear_id, device_id, sport, start_time, duration_sec, distance_m,
                         avg_speed_mps, avg_hr, source, notes)
   VALUES (@athlete_id, @gear_id, @device_id, @sport, @start_time, @duration_sec, @distance_m,
           @avg_speed_mps, @avg_hr, 'manual', @notes)`);

app.post('/api/activities', (req, res) => {
  const id = insertActivity.run(cleanActivity(req.body)).lastInsertRowid;
  res.status(201).json({ message: `Activity #${id} saved`, activity_id: Number(id) });
});

// delete / update
app.delete('/api/activities/:id', (req, res) => {
  const info = db.prepare('DELETE FROM activity WHERE activity_id = ?').run(req.params.id);
  if (info.changes === 0) throw new UserError('Activity not found', 404);
  res.json({ message: `Activity #${req.params.id} deleted` });
});

app.post('/api/gear/:id/retire', (req, res) => {
  const info = db.prepare(
    `UPDATE gear SET is_retired = 1, retired_date = date('now') WHERE gear_id = ? AND is_retired = 0`
  ).run(req.params.id);
  if (info.changes === 0) throw new UserError('Gear not found or already retired', 404);
  res.json({ message: 'Gear retired' });
});

// record an event result (uses a transaction)
// Two changes must succeed together: insert the activity, then mark the registration completed.
// If the athlete is not registered, the error rolls back the activity insert.
const recordResult = db.transaction((b) => {
  const eventId = Number(b.event_id);
  const event = db.prepare('SELECT name, sport FROM event WHERE event_id = ?').get(eventId);
  if (!event) throw new UserError('Choose an event');

  const data = cleanActivity({ ...b, sport: event.sport });
  data.notes = data.notes || event.name;
  const activityId = Number(insertActivity.run(data).lastInsertRowid);

  const info = db.prepare(
    `UPDATE event_registration
        SET activity_id = ?, finish_time_sec = ?, overall_placement = ?, status = 'completed'
      WHERE athlete_id = ? AND event_id = ? AND status = 'registered'`
  ).run(activityId, data.duration_sec, b.placement ? Number(b.placement) : null, data.athlete_id, eventId);
  if (info.changes === 0) throw new UserError('That athlete has no open registration for this event');
  return activityId;
});

app.post('/api/event-results', (req, res) => {
  const id = recordResult(req.body);
  res.status(201).json({ message: `Result saved (activity #${id}, registration marked completed)` });
});

//  error handling
app.use('/api', (req, res) => res.status(404).json({ error: 'No such endpoint' }));

app.use((err, req, res, next) => {
  if (err instanceof UserError) return res.status(err.status).json({ error: err.message });
  if (err.code === 'SQLITE_CONSTRAINT_UNIQUE' || err.code === 'SQLITE_CONSTRAINT_PRIMARYKEY') {
    return res.status(409).json({ error: 'That record already exists (duplicate value)' });
  }
  if (typeof err.code === 'string' && err.code.startsWith('SQLITE_CONSTRAINT')) {
    return res.status(400).json({ error: 'The database rejected that data (a rule or foreign key was violated)' });
  }
  console.error(err);
  res.status(500).json({ error: 'Something went wrong. Please try again.' });
});

const PORT = process.env.PORT || 3000;
const server = app.listen(PORT, () => console.log(`Ride & Run Tracker: http://localhost:${PORT}`));

function shutdown() {
  server.close();
  db.close(); // close the database connection cleanly
  process.exit(0);
}
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
