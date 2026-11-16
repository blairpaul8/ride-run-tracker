-- Ride & Run Tracker: transaction example
--
-- Scenario: Riley Chen finishes the Saturday Morning Group Ride (event 2) and
-- uploads the ride. Recording it takes three related changes:
--   1. insert the new activity,
--   2. insert its laps,
--   3. update Riley's event registration to point at the activity and mark it completed.
-- If any one step fails, the other two must not stay behind, otherwise the database
-- would hold an orphan activity or a "completed" registration with no activity.
--
-- Both parts end in ROLLBACK so this file can be run repeatedly without changing
-- the sample data. To keep the changes, replace the Part A ROLLBACK with COMMIT.

PRAGMA foreign_keys = ON;

-- Before: Riley has 4 activities, and registration for event 2 is 'registered'.
SELECT 'before' AS stage,
       (SELECT COUNT(*) FROM activity WHERE athlete_id = 4)                        AS riley_activities,
       (SELECT COUNT(*) FROM lap WHERE activity_id = 17)                           AS new_laps,
       (SELECT status FROM event_registration WHERE athlete_id = 4 AND event_id = 2) AS registration_status;


-- Part A: all three steps succeed together (then rolled back for the demo)
--
BEGIN TRANSACTION;

-- Step 1: the ride Riley uploaded 48 km on the Roubaix with the Edge 840.
INSERT INTO activity (activity_id, athlete_id, gear_id, device_id, sport, start_time,
                      duration_sec, distance_m, avg_speed_mps, avg_hr, max_hr,
                      elevation_gain_m, calories, avg_cadence, source, source_file_name,
                      file_hash, notes)
VALUES (17, 4, 9, 8, 'cycling', '2026-10-24T08:00:00Z',
        6120, 48000.0, 7.843, 139, 152,
        512.0, 1480, 90, 'upload', 'riley_2026-10-24_ride.fit',
        'a3f1c2d4e5b60718293a4b5c6d7e8f90a1b2c3d4e5f60718293a4b5c6d7e8f90',
        'Saturday Morning Group Ride');

-- Step 2: the laps of that ride (distances and durations add up to the activity).
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (17, 1, 16000.0, 2050, 136),
    (17, 2, 16000.0, 2030, 139),
    (17, 3, 16000.0, 2040, 142);

-- Step 3: link the result to the registration and mark it completed.
UPDATE event_registration
SET activity_id     = 17,
    finish_time_sec = 6120,
    status          = 'completed'
WHERE athlete_id = 4
  AND event_id   = 2;

-- Inside the transaction all three changes are visible together.
SELECT 'inside Part A' AS stage,
       (SELECT COUNT(*) FROM activity WHERE athlete_id = 4)                        AS riley_activities,
       (SELECT COUNT(*) FROM lap WHERE activity_id = 17)                           AS new_laps,
       (SELECT status FROM event_registration WHERE athlete_id = 4 AND event_id = 2) AS registration_status;

-- Undo everything so the sample data is unchanged. Use COMMIT here to keep it.
ROLLBACK;

SELECT 'after Part A rollback' AS stage,
       (SELECT COUNT(*) FROM activity WHERE athlete_id = 4)                        AS riley_activities,
       (SELECT COUNT(*) FROM lap WHERE activity_id = 17)                           AS new_laps,
       (SELECT status FROM event_registration WHERE athlete_id = 4 AND event_id = 2) AS registration_status;


-- Part B: a step fails, so the earlier steps must be undone too
--
-- The activity and laps insert fine, but step 3 uses an invalid status value
-- ('finished' is not allowed), so the CHECK constraint rejects it. The sqlite3
-- shell prints "CHECK constraint failed" for that statement and keeps going;
-- ROLLBACK then removes the activity and laps that were already inserted.
BEGIN TRANSACTION;

INSERT INTO activity (activity_id, athlete_id, gear_id, device_id, sport, start_time,
                      duration_sec, distance_m, avg_speed_mps, avg_hr, max_hr,
                      elevation_gain_m, calories, avg_cadence, source, source_file_name,
                      file_hash, notes)
VALUES (17, 4, 9, 8, 'cycling', '2026-10-24T08:00:00Z',
        6120, 48000.0, 7.843, 139, 152,
        512.0, 1480, 90, 'upload', 'riley_2026-10-24_ride.fit',
        'a3f1c2d4e5b60718293a4b5c6d7e8f90a1b2c3d4e5f60718293a4b5c6d7e8f90',
        'Saturday Morning Group Ride');

INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (17, 1, 16000.0, 2050, 136),
    (17, 2, 16000.0, 2030, 139),
    (17, 3, 16000.0, 2040, 142);

-- This statement fails: finished is not one of registered / completed / DNF / withdrawn.
UPDATE event_registration
SET activity_id     = 17,
    finish_time_sec = 6120,
    status          = 'finished'
WHERE athlete_id = 4
  AND event_id   = 2;

-- The activity and laps are still in the open transaction at this point
SELECT 'inside Part B (step 3 failed)' AS stage,
       (SELECT COUNT(*) FROM activity WHERE athlete_id = 4)                        AS riley_activities,
       (SELECT COUNT(*) FROM lap WHERE activity_id = 17)                           AS new_laps,
       (SELECT status FROM event_registration WHERE athlete_id = 4 AND event_id = 2) AS registration_status;

-- roll back to leave no half-finished result behind.
ROLLBACK;

SELECT 'after Part B rollback' AS stage,
       (SELECT COUNT(*) FROM activity WHERE athlete_id = 4)                        AS riley_activities,
       (SELECT COUNT(*) FROM lap WHERE activity_id = 17)                           AS new_laps,
       (SELECT status FROM event_registration WHERE athlete_id = 4 AND event_id = 2) AS registration_status;
