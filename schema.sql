-- Ride & Run Tracker: SQLite schema
-- Usage: sqlite3 run_ride.db

PRAGMA foreign_keys = ON;  -- must be set on every connection; SQLite does not persist it

-- Reset: drop everything so this file can be re-run safely
DROP VIEW  IF EXISTS gear_mileage;
DROP INDEX IF EXISTS idx_activity_athlete_time;
DROP TABLE IF EXISTS event_registration;
DROP TABLE IF EXISTS goal;
DROP TABLE IF EXISTS lap;
DROP TABLE IF EXISTS hr_zone;
DROP TABLE IF EXISTS activity;
DROP TABLE IF EXISTS event;
DROP TABLE IF EXISTS device;
DROP TABLE IF EXISTS gear;
DROP TABLE IF EXISTS athlete;

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

CREATE TABLE athlete (
    athlete_id      INTEGER PRIMARY KEY,
    first_name      TEXT NOT NULL,
    last_name       TEXT NOT NULL,
    email           TEXT NOT NULL UNIQUE,
    birth_date      TEXT,                                   -- ISO 8601 date
    preferred_units TEXT NOT NULL DEFAULT 'mi'
                    CHECK (preferred_units IN ('mi', 'km')),
    created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
);

CREATE TABLE gear (
    gear_id                INTEGER PRIMARY KEY,
    athlete_id             INTEGER NOT NULL
                           REFERENCES athlete(athlete_id) ON DELETE CASCADE,
    gear_type              TEXT NOT NULL CHECK (gear_type IN ('bike', 'shoes')),
    name                   TEXT NOT NULL,
    brand                  TEXT,
    model                  TEXT,
    purchase_date          TEXT,                            -- ISO 8601 date
    retirement_threshold_m REAL CHECK (retirement_threshold_m IS NULL OR retirement_threshold_m > 0),
    is_retired             INTEGER NOT NULL DEFAULT 0 CHECK (is_retired IN (0, 1)),
    retired_date           TEXT,
    CHECK (is_retired = 1 OR retired_date IS NULL)
);

CREATE TABLE device (
    device_id   INTEGER PRIMARY KEY,
    athlete_id  INTEGER NOT NULL
                REFERENCES athlete(athlete_id) ON DELETE CASCADE,
    device_name TEXT NOT NULL,
    model       TEXT,
    device_type TEXT NOT NULL
                CHECK (device_type IN ('bike computer', 'watch', 'phone'))
);

CREATE TABLE activity (
    activity_id      INTEGER PRIMARY KEY,
    athlete_id       INTEGER NOT NULL
                     REFERENCES athlete(athlete_id) ON DELETE CASCADE,
    gear_id          INTEGER REFERENCES gear(gear_id)     ON DELETE SET NULL,
    device_id        INTEGER REFERENCES device(device_id) ON DELETE SET NULL,
    sport            TEXT NOT NULL CHECK (sport IN ('cycling', 'running')),
    start_time       TEXT NOT NULL,                         -- ISO 8601 datetime
    duration_sec     INTEGER NOT NULL CHECK (duration_sec > 0),
    distance_m       REAL    NOT NULL CHECK (distance_m >= 0),
    avg_speed_mps    REAL    CHECK (avg_speed_mps IS NULL OR avg_speed_mps >= 0),
    avg_hr           INTEGER CHECK (avg_hr IS NULL OR avg_hr > 0),
    max_hr           INTEGER CHECK (max_hr IS NULL OR max_hr > 0),
    elevation_gain_m REAL    CHECK (elevation_gain_m IS NULL OR elevation_gain_m >= 0),
    calories         INTEGER CHECK (calories IS NULL OR calories >= 0),
    avg_cadence      INTEGER CHECK (avg_cadence IS NULL OR avg_cadence >= 0),
    source           TEXT NOT NULL CHECK (source IN ('upload', 'manual')),
    source_file_name TEXT,
    file_hash        TEXT UNIQUE,                           -- NULLs allowed; duplicates of non-NULL rejected
    notes            TEXT,
    CHECK (avg_hr IS NULL OR max_hr IS NULL OR max_hr >= avg_hr)
);

CREATE TABLE lap (
    lap_id       INTEGER PRIMARY KEY,
    activity_id  INTEGER NOT NULL
                 REFERENCES activity(activity_id) ON DELETE CASCADE,
    lap_number   INTEGER NOT NULL CHECK (lap_number >= 1),
    distance_m   REAL    NOT NULL CHECK (distance_m >= 0),
    duration_sec INTEGER NOT NULL CHECK (duration_sec > 0),
    avg_hr       INTEGER CHECK (avg_hr IS NULL OR avg_hr > 0),
    UNIQUE (activity_id, lap_number)
);

CREATE TABLE hr_zone (
    hr_zone_id  INTEGER PRIMARY KEY,
    athlete_id  INTEGER NOT NULL
                REFERENCES athlete(athlete_id) ON DELETE CASCADE,
    zone_number INTEGER NOT NULL CHECK (zone_number BETWEEN 1 AND 5),
    min_bpm     INTEGER NOT NULL CHECK (min_bpm > 0),
    max_bpm     INTEGER NOT NULL,
    CHECK (max_bpm >= min_bpm),
    UNIQUE (athlete_id, zone_number)
);

CREATE TABLE event (
    event_id   INTEGER PRIMARY KEY,
    name       TEXT NOT NULL,
    event_type TEXT NOT NULL CHECK (event_type IN ('race', 'group ride', 'group run')),
    sport      TEXT NOT NULL CHECK (sport IN ('cycling', 'running')),
    event_date TEXT NOT NULL,                               -- ISO 8601 date
    location   TEXT,
    distance_m REAL CHECK (distance_m IS NULL OR distance_m > 0)
);

CREATE TABLE goal (
    goal_id      INTEGER PRIMARY KEY,
    athlete_id   INTEGER NOT NULL
                 REFERENCES athlete(athlete_id) ON DELETE CASCADE,
    event_id     INTEGER REFERENCES event(event_id) ON DELETE SET NULL,
    sport        TEXT CHECK (sport IS NULL OR sport IN ('cycling', 'running')),  -- NULL = both
    goal_type    TEXT NOT NULL
                 CHECK (goal_type IN ('distance', 'time', 'frequency', 'race_time')),
    target_value REAL NOT NULL CHECK (target_value > 0),
    target_unit  TEXT NOT NULL,
    start_date   TEXT NOT NULL,
    end_date     TEXT NOT NULL,
    status       TEXT NOT NULL DEFAULT 'active'
                 CHECK (status IN ('active', 'achieved', 'missed')),
    CHECK (end_date >= start_date),
    CHECK (goal_type = 'race_time' OR event_id IS NULL)     -- event link only for race-time goals
);

-- Junction table resolving the Athlete <-> Event many-to-many
CREATE TABLE event_registration (
    athlete_id        INTEGER NOT NULL
                      REFERENCES athlete(athlete_id) ON DELETE CASCADE,
    event_id          INTEGER NOT NULL
                      REFERENCES event(event_id) ON DELETE CASCADE,
    activity_id       INTEGER UNIQUE
                      REFERENCES activity(activity_id) ON DELETE SET NULL,  -- result activity
    registration_date TEXT NOT NULL,
    bib_number        INTEGER,
    finish_time_sec   INTEGER CHECK (finish_time_sec IS NULL OR finish_time_sec > 0),
    overall_placement INTEGER CHECK (overall_placement IS NULL OR overall_placement >= 1),
    status            TEXT NOT NULL DEFAULT 'registered'
                      CHECK (status IN ('registered', 'completed', 'DNF', 'withdrawn')),
    PRIMARY KEY (athlete_id, event_id)
) WITHOUT ROWID;


-- ---------------------------------------------------------------------------
-- Index
-- ---------------------------------------------------------------------------

CREATE INDEX idx_activity_athlete_time ON activity(athlete_id, start_time);
 
-- ---------------------------------------------------------------------------
-- View
-- ---------------------------------------------------------------------------

CREATE VIEW gear_mileage AS
SELECT
    g.gear_id,
    g.athlete_id,
    a.first_name || ' ' || a.last_name        AS athlete_name,
    g.gear_type,
    g.name                                    AS gear_name,
    g.brand,
    g.model,
    g.is_retired,
    g.retirement_threshold_m,
    COUNT(ac.activity_id)                     AS activity_count,
    COALESCE(SUM(ac.distance_m), 0)           AS total_distance_m,
    CASE WHEN g.retirement_threshold_m IS NULL THEN NULL
         ELSE ROUND(100.0 * COALESCE(SUM(ac.distance_m), 0) / g.retirement_threshold_m, 1)
    END                                       AS pct_of_threshold,
    CASE WHEN g.is_retired = 0
          AND g.retirement_threshold_m IS NOT NULL
          AND COALESCE(SUM(ac.distance_m), 0) >= g.retirement_threshold_m
         THEN 1 ELSE 0
    END                                       AS due_for_retirement
FROM gear g
JOIN athlete a            ON a.athlete_id = g.athlete_id
LEFT JOIN activity ac     ON ac.gear_id   = g.gear_id
GROUP BY g.gear_id;
 
