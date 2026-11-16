// Rebuilds run_ride.db from schema.sql + insert_data.sql:  npm run reset
const fs = require('fs');
const Database = require('better-sqlite3');
const file = process.env.DB_PATH || 'run_ride.db';
fs.rmSync(file, { force: true });
const db = new Database(file);
db.exec(fs.readFileSync('schema.sql', 'utf8'));
db.exec(fs.readFileSync('insert_data.sql', 'utf8'));
console.log('Database rebuilt:', file);
db.close();
