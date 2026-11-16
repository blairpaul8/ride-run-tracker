# Ride & Run Tracker (Deliverable 5)

A small web application for logging cycling and running activities.
**Language:** JavaScript (Node.js). **Backend:** Express. **Database:** SQLite (`run_ride.db`).
**Frontend:** one HTML page with plain JavaScript and Tailwind CSS (loaded from a CDN, so an internet connection is needed to see the styling).

## Requirements

- Node.js 22 or newer (`node -v` to check)
- Packages (installed by `npm install`): `express`, `better-sqlite3`

## Setup and run

```bash
npm install
npm start
```

Then open **http://localhost:3000** in a browser. Stop the server with Ctrl+C (the database connection is closed cleanly).

> Run `npm start`, not `node start`.
> If `npm install` shows a `node-gyp` error, delete any `package-lock.json` in this folder and run it again.

## Database configuration

No configuration is needed. The app opens `run_ride.db` in this folder, and no passwords or keys are involved.
To use another file, set `DB_PATH` (for example `DB_PATH=/tmp/test.db npm start`).

To recreate the database from the submitted backend files (this replaces all current data with the sample data):

```bash
npm run reset
```

This runs `schema.sql` and then `insert_data.sql`. The database was not changed during application development,
so these are the same files as Deliverables 3 and 4.

## The six required operations

| # | Category | Where to find it in the app | API endpoint |
|---|---|---|---|
| 1 | Search or browse | **Activities** tab: filter by athlete and sport | `GET /api/activities?sport=&athlete_id=` |
| 2 | Display related data | **Reports** tab: queries 2, 3 and 4 (joins). The activity list also joins athlete, gear and device | `GET /api/queries/2`, `/3`, `/4` |
| 3 | Add data | **Activities** tab: "Add an activity" form | `POST /api/activities` (INSERT) |
| 4 | Update or delete | **Activities** tab: Delete button on a row. **Gear** tab: Retire button | `DELETE /api/activities/:id`, `POST /api/gear/:id/retire` (UPDATE) |
| 5 | Summary or report | **Reports** tab: queries 5 (aggregates), 6 (GROUP BY/HAVING), 7 (subquery), 9 (view) | `GET /api/queries/5`, `/6`, `/7`, `/9` |
| 6 | Additional operation | **Event result** tab: records a race or group ride result | `POST /api/event-results` |

Operation 6 uses a **transaction**: it inserts the activity and then marks the athlete's event registration as completed.
If the second step fails (for example the athlete is not registered), the first is rolled back.

## The 9 query endpoints

`GET /api/queries` lists them and `GET /api/queries/1` ... `/9` run them. The SQL is read directly from `queries.sql`
when the server starts, so that file is the only place the query SQL lives.

| Endpoint | Query |
|---|---|
| `/api/queries/1` | Filtering and sorting (long rides) |
| `/api/queries/2` | INNER JOIN (activity log in preferred units) |
| `/api/queries/3` | LEFT JOIN (gear usage) |
| `/api/queries/4` | Three-table join (event results) |
| `/api/queries/5` | Aggregates (running totals) |
| `/api/queries/6` | GROUP BY and HAVING (zone 2 pace by week) |
| `/api/queries/7` | Subquery (goal progress) |
| `/api/queries/8` | Set operation, EXCEPT (registered but never completed) |
| `/api/queries/9` | View (gear closest to retirement) |

## Input validation and errors

- All SQL with user-supplied values uses `?` placeholders or named parameters. No SQL is built from user input.
- The server checks required fields, sport, positive distance and duration, heart rate range, valid date,
  and that the gear and device belong to the chosen athlete and the gear type matches the sport.
- Not-found, duplicate, constraint and foreign-key errors come back as short readable messages (shown in a banner at the top of the page), never as stack traces.
- Foreign keys are enforced (`PRAGMA foreign_keys = ON`).

## Files

| File | Purpose |
|---|---|
| `server.js` | Express server: all endpoints, validation, the transaction, error handling |
| `public/index.html` | The whole frontend |
| `queries.sql` | The 9 queries (also read by the server) |
| `schema.sql`, `insert_data.sql` | Recreate the database |
| `transaction.sql` | Deliverable 4 transaction example |
| `reset-db.js` | `npm run reset` helper |
| `run_ride.db` | The SQLite database |
