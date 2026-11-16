-- Ride & Run Tracker: sample data
-- Load AFTER schema.sql:  sqlite3 tracker.db < insert_data.sql

PRAGMA foreign_keys = ON;
BEGIN TRANSACTION;

-- athlete
INSERT INTO athlete (athlete_id, first_name, last_name, email, birth_date, preferred_units, created_at) VALUES
    (1, 'Maya', 'Torres', 'maya.torres@example.com', '1998-03-14', 'mi', '2026-08-28T12:00:00Z'),  -- Maya Torres
    (2, 'Jordan', 'Lee', 'jordan.lee@example.com', '1991-11-02', 'km', '2026-08-28T12:00:00Z'),  -- Jordan Lee
    (3, 'Sam', 'Patel', 'sam.patel@example.com', '2001-07-25', 'mi', '2026-08-28T12:00:00Z'),  -- Sam Patel
    (4, 'Riley', 'Chen', 'riley.chen@example.com', '1995-05-09', 'km', '2026-08-28T12:00:00Z');  -- Riley Chen

-- gear
INSERT INTO gear (gear_id, athlete_id, gear_type, name, brand, model, purchase_date, retirement_threshold_m, is_retired, retired_date) VALUES
    (1, 1, 'bike', 'Domane SL5', 'Trek', 'Domane SL 5', '2024-04-12', NULL, 0, NULL),  -- Maya: Domane SL5
    (2, 1, 'shoes', 'Ghost 15', 'Brooks', 'Ghost 15', '2026-06-01', 800000, 0, NULL),  -- Maya: Ghost 15
    (3, 1, 'shoes', 'Ghost 14', 'Brooks', 'Ghost 14', '2025-05-10', 800000, 1, '2026-05-30'),  -- Maya: Ghost 14
    (4, 2, 'bike', 'Tarmac', 'Specialized', 'Tarmac SL7', '2023-08-20', NULL, 0, NULL),  -- Jordan: Tarmac
    (5, 2, 'bike', 'Gravel', 'Canyon', 'Grail CF SL', '2025-02-14', NULL, 0, NULL),  -- Jordan: Gravel
    (6, 2, 'shoes', 'Clifton 9', 'Hoka', 'Clifton 9', '2026-03-03', 700000, 0, NULL),  -- Jordan: Clifton 9
    (7, 3, 'shoes', 'Pegasus 41', 'Nike', 'Pegasus 41', '2026-04-18', 800000, 0, NULL),  -- Sam: Pegasus 41
    (8, 3, 'shoes', 'Endorphin Speed 4', 'Saucony', 'Endorphin Speed 4', '2026-08-01', 500000, 0, NULL),  -- Sam: Endorphin Speed 4
    (9, 4, 'bike', 'Roubaix', 'Specialized', 'Roubaix Comp', '2025-09-05', NULL, 0, NULL),  -- Riley: Roubaix
    (10, 4, 'shoes', 'Novablast 4', 'ASICS', 'Novablast 4', '2026-05-20', 750000, 0, NULL);  -- Riley: Novablast 4

-- device
INSERT INTO device (device_id, athlete_id, device_name, model, device_type) VALUES
    (1, 1, 'Forerunner 255', 'Garmin Forerunner 255', 'watch'),  -- Maya: Forerunner 255
    (2, 1, 'Edge 530', 'Garmin Edge 530', 'bike computer'),  -- Maya: Edge 530
    (3, 2, 'ELEMNT Bolt', 'Wahoo ELEMNT Bolt v2', 'bike computer'),  -- Jordan: ELEMNT Bolt
    (4, 2, 'Apple Watch', 'Apple Watch Series 9', 'watch'),  -- Jordan: Apple Watch
    (5, 3, 'Pace 3', 'Coros Pace 3', 'watch'),  -- Sam: Pace 3
    (6, 3, 'iPhone', 'Apple iPhone 15', 'phone'),  -- Sam: iPhone
    (7, 4, 'Venu 3', 'Garmin Venu 3', 'watch'),  -- Riley: Venu 3
    (8, 4, 'Edge 840', 'Garmin Edge 840', 'bike computer');  -- Riley: Edge 840

-- hr_zone
INSERT INTO hr_zone (hr_zone_id, athlete_id, zone_number, min_bpm, max_bpm) VALUES
    (1, 1, 1, 94, 113),  -- Maya: zone 1
    (2, 1, 2, 114, 132),  -- Maya: zone 2
    (3, 1, 3, 133, 150),  -- Maya: zone 3
    (4, 1, 4, 151, 169),  -- Maya: zone 4
    (5, 1, 5, 170, 188),  -- Maya: zone 5
    (6, 2, 1, 96, 115),  -- Jordan: zone 1
    (7, 2, 2, 116, 134),  -- Jordan: zone 2
    (8, 2, 3, 135, 154),  -- Jordan: zone 3
    (9, 2, 4, 155, 173),  -- Jordan: zone 4
    (10, 2, 5, 174, 192),  -- Jordan: zone 5
    (11, 3, 1, 98, 117),  -- Sam: zone 1
    (12, 3, 2, 118, 136),  -- Sam: zone 2
    (13, 3, 3, 137, 156),  -- Sam: zone 3
    (14, 3, 4, 157, 176),  -- Sam: zone 4
    (15, 3, 5, 177, 195),  -- Sam: zone 5
    (16, 4, 1, 93, 112),  -- Riley: zone 1
    (17, 4, 2, 113, 130),  -- Riley: zone 2
    (18, 4, 3, 131, 149),  -- Riley: zone 3
    (19, 4, 4, 150, 167),  -- Riley: zone 4
    (20, 4, 5, 168, 186);  -- Riley: zone 5

-- event
INSERT INTO event (event_id, name, event_type, sport, event_date, location, distance_m) VALUES
    (1, 'Knoxville Fall 10K', 'race', 'running', '2026-10-17', 'Knoxville, TN', 10000.0),  -- Knoxville Fall 10K
    (2, 'Saturday Morning Group Ride', 'group ride', 'cycling', '2026-10-24', 'Knoxville, TN', 48000.0),  -- Saturday Morning Group Ride
    (3, 'Smoky Mountain Gran Fondo', 'race', 'cycling', '2026-11-14', 'Townsend, TN', 100000.0);  -- Smoky Mountain Gran Fondo

-- goal
INSERT INTO goal (goal_id, athlete_id, event_id, sport, goal_type, target_value, target_unit, start_date, end_date, status) VALUES
    (1, 1, 1, 'running', 'race_time', 3100, 'seconds', '2026-09-01', '2026-10-17', 'achieved'),  -- Maya: race_time (achieved)
    (2, 1, NULL, NULL, 'distance', 150, 'km', '2026-10-01', '2026-10-31', 'active'),  -- Maya: distance (active)
    (3, 2, NULL, 'cycling', 'frequency', 4, 'activities per week', '2026-09-01', '2026-12-31', 'active'),  -- Jordan: frequency (active)
    (4, 2, NULL, 'cycling', 'distance', 400, 'km', '2026-10-01', '2026-10-31', 'active'),  -- Jordan: distance (active)
    (5, 3, 1, 'running', 'race_time', 3400, 'seconds', '2026-09-01', '2026-10-17', 'achieved'),  -- Sam: race_time (achieved)
    (6, 3, NULL, 'running', 'time', 1200, 'minutes', '2026-10-01', '2026-10-31', 'active'),  -- Sam: time (active)
    (7, 4, NULL, 'running', 'frequency', 3, 'activities per week', '2026-09-01', '2026-09-30', 'missed'),  -- Riley: frequency (missed)
    (8, 4, NULL, 'cycling', 'distance', 250, 'km', '2026-10-01', '2026-10-31', 'active');  -- Riley: distance (active)

-- activity
INSERT INTO activity (activity_id, athlete_id, gear_id, device_id, sport, start_time, duration_sec, distance_m, avg_speed_mps, avg_hr, max_hr, elevation_gain_m, calories, avg_cadence, source, source_file_name, file_hash, notes) VALUES
    (1, 1, 1, 2, 'cycling', '2026-09-06T06:45:00Z', 3276, 25000.0, 7.631, 131, 142, 250.3, 757, 92, 'upload', 'maya_2026-09-06_ride.fit', '053adcc5558b872138030b4c66c9a9314c04295c4ac20e1bbdb0d73b64acd9fb', 'Legs tired'),  -- Maya: cycling 2026-09-06
    (2, 1, 1, NULL, 'cycling', '2026-09-17T17:45:00Z', 5397, 40000.0, 7.412, 132, 144, 446.8, 1307, 88, 'manual', NULL, NULL, 'Group ride'),  -- Maya: cycling 2026-09-17 (manual)
    (3, 1, 2, 1, 'running', '2026-10-03T06:45:00Z', 2253, 7000.0, 3.107, 126, 137, 42.9, 505, 170, 'upload', 'maya_2026-10-03_run.fit', '5840370b3f34d2786362bdeb770f7afefad5ef5233c8d7e44ccf54957d0e62cc', 'Felt good'),  -- Maya: running 2026-10-03
    (4, 1, 2, 1, 'running', '2026-10-17T08:00:00Z', 2754, 10000.0, 3.631, 160, 175, 72.1, 671, 171, 'upload', 'maya_2026-10-17_run.fit', 'dd9e1378b6b4750cbc1b9c936210642360c39471e7f0c7afa728a0d4ac735a7e', 'Race day - Fall 10K'),  -- Maya: running 2026-10-17
    (5, 2, 4, 3, 'cycling', '2026-09-05T06:15:00Z', 4829, 40000.0, 8.283, 136, 146, 472.0, 1259, 90, 'upload', 'jordan_2026-09-05_ride.fit', 'a17cfc6e026a1395bc21f9b0f4fc29e9d794b02a1983dd85af954181878276dc', 'Legs tired'),  -- Jordan: cycling 2026-09-05
    (6, 2, 6, 4, 'running', '2026-09-10T11:15:00Z', 1574, 5000.0, 3.177, 121, 133, 36.9, 350, 169, 'upload', 'jordan_2026-09-10_run.fit', '5214f9f3dfc5312b0092e4b911d595364f955802a350c3ad7036b4c2838d0e3d', NULL),  -- Jordan: running 2026-09-10
    (7, 2, 5, 3, 'cycling', '2026-09-13T07:45:00Z', 3662, 30000.0, 8.192, 132, 143, 315.4, 943, 90, 'upload', 'jordan_2026-09-13_ride.fit', '8a5d485e7fcd3da03f7c56ff1d73e41e37646c3a596918ccb8ec41e01793af5a', 'Group ride'),  -- Jordan: cycling 2026-09-13
    (8, 2, 4, 3, 'cycling', '2026-10-08T07:30:00Z', 7231, 60000.0, 8.298, 136, 154, 784.3, 1779, 90, 'upload', 'jordan_2026-10-08_ride.fit', 'bdfdd1c7e44ba67984e6deef1108263e75f566a9d563a1f0ba559fb6e7eb0623', 'Legs tired'),  -- Jordan: cycling 2026-10-08
    (9, 3, 7, 5, 'running', '2026-09-02T11:30:00Z', 1753, 5000.0, 2.852, 126, 136, 37.9, 354, 170, 'upload', 'sam_2026-09-02_run.fit', '6f881f2bf65ac0ad24b30764234c1f7a1c993a98d6f87ba7ab7b801d9ae3fbf2', 'Felt good'),  -- Sam: running 2026-09-02
    (10, 3, NULL, 6, 'cycling', '2026-09-13T06:00:00Z', 3941, 25000.0, 6.344, 136, 145, 272.4, 807, 90, 'upload', 'sam_2026-09-13_ride.fit', '6ae5cfacb8f0bb9faabb42a0efae22f5accafbf1ffbb78f7a8a1dedf9ae4281f', NULL),  -- Sam: cycling 2026-09-13
    (11, 3, NULL, NULL, 'cycling', '2026-09-30T17:45:00Z', 6138, 40000.0, 6.517, 148, 153, 339.7, 1321, 91, 'manual', NULL, NULL, NULL),  -- Sam: cycling 2026-09-30 (manual)
    (12, 3, 8, 5, 'running', '2026-10-17T08:00:00Z', 2889, 10000.0, 3.461, 170, 180, 84.7, 665, 169, 'upload', 'sam_2026-10-17_run.fit', '111c2959c2c22391142c6eef611990b4be13dbc58bb4d44c163b1c298f52d047', 'Race day - Fall 10K'),  -- Sam: running 2026-10-17
    (13, 4, 10, 7, 'running', '2026-09-02T17:00:00Z', 1625, 5000.0, 3.077, 120, 132, 34.8, 355, 166, 'upload', 'riley_2026-09-02_run.fit', '99a44f6ff34daeebc286f72ca65881493bb108f284a5d927f2257c52992c1d1a', 'Windy'),  -- Riley: running 2026-09-02
    (14, 4, 9, 8, 'cycling', '2026-09-09T17:45:00Z', 5028, 40000.0, 7.955, 137, 150, 529.0, 1191, 82, 'upload', 'riley_2026-09-09_ride.fit', '7e6c1a8fec276308a3188f81ae4a89b910c0d4a08f0469d7d2c2b6f059ff46c5', 'Felt good'),  -- Riley: cycling 2026-09-09
    (15, 4, 10, 7, 'running', '2026-09-13T17:00:00Z', 1904, 6000.0, 3.151, 124, 135, 30.9, 424, 166, 'upload', 'riley_2026-09-13_run.fit', '689cdca3e324522460ac4c22d99cbbd373350aeac7bb7cf02f79698224d4595b', 'Windy'),  -- Riley: running 2026-09-13
    (16, 4, 9, 8, 'cycling', '2026-10-12T06:30:00Z', 5672, 45000.0, 7.934, 137, 150, 460.5, 1447, 91, 'upload', 'riley_2026-10-12_ride.fit', 'b63810a37ca942fc16ca31e22039aa031266eeb8fbb67560cda61d004a906ba6', 'Felt good');  -- Riley: cycling 2026-10-12

-- lap (lap_id is assigned automatically)
-- activity 1: Maya, cycling 2026-09-06
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (1, 1, 5000.0, 670, 130),
    (1, 2, 5000.0, 640, 130),
    (1, 3, 5000.0, 649, 133),
    (1, 4, 5000.0, 664, 131),
    (1, 5, 5000.0, 653, 129);
-- activity 2: Maya, cycling 2026-09-17
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (2, 1, 5000.0, 692, 131),
    (2, 2, 5000.0, 681, 132),
    (2, 3, 5000.0, 663, 134),
    (2, 4, 5000.0, 670, 132),
    (2, 5, 5000.0, 662, 132),
    (2, 6, 5000.0, 682, 130),
    (2, 7, 5000.0, 683, 133),
    (2, 8, 5000.0, 664, 135);
-- activity 3: Maya, running 2026-10-03
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (3, 1, 1000.0, 310, 124),
    (3, 2, 1000.0, 317, 122),
    (3, 3, 1000.0, 322, 125),
    (3, 4, 1000.0, 329, 128),
    (3, 5, 1000.0, 316, 126),
    (3, 6, 1000.0, 331, 128),
    (3, 7, 1000.0, 328, 130);
-- activity 4: Maya, running 2026-10-17
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (4, 1, 1000.0, 276, 158),
    (4, 2, 1000.0, 282, 158),
    (4, 3, 1000.0, 273, 158),
    (4, 4, 1000.0, 281, 158),
    (4, 5, 1000.0, 282, 158),
    (4, 6, 1000.0, 280, 160),
    (4, 7, 1000.0, 269, 160),
    (4, 8, 1000.0, 275, 161),
    (4, 9, 1000.0, 269, 164),
    (4, 10, 1000.0, 267, 162);
-- activity 5: Jordan, cycling 2026-09-05
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (5, 1, 5000.0, 619, 131),
    (5, 2, 5000.0, 604, 134),
    (5, 3, 5000.0, 575, 134),
    (5, 4, 5000.0, 620, 136),
    (5, 5, 5000.0, 615, 137),
    (5, 6, 5000.0, 602, 136),
    (5, 7, 5000.0, 584, 139),
    (5, 8, 5000.0, 610, 138);
-- activity 6: Jordan, running 2026-09-10
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (6, 1, 1000.0, 318, 119),
    (6, 2, 1000.0, 314, 119),
    (6, 3, 1000.0, 321, 122),
    (6, 4, 1000.0, 310, 121),
    (6, 5, 1000.0, 311, 124);
-- activity 7: Jordan, cycling 2026-09-13
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (7, 1, 5000.0, 611, 132),
    (7, 2, 5000.0, 599, 133),
    (7, 3, 5000.0, 610, 133),
    (7, 4, 5000.0, 598, 132),
    (7, 5, 5000.0, 617, 132),
    (7, 6, 5000.0, 627, 131);
-- activity 8: Jordan, cycling 2026-10-08
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (8, 1, 5000.0, 603, 128),
    (8, 2, 5000.0, 618, 130),
    (8, 3, 5000.0, 608, 131),
    (8, 4, 5000.0, 611, 133),
    (8, 5, 5000.0, 596, 136),
    (8, 6, 5000.0, 611, 134),
    (8, 7, 5000.0, 598, 135),
    (8, 8, 5000.0, 587, 138),
    (8, 9, 5000.0, 585, 141),
    (8, 10, 5000.0, 594, 143),
    (8, 11, 5000.0, 621, 143),
    (8, 12, 5000.0, 599, 141);
-- activity 9: Sam, running 2026-09-02
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (9, 1, 1000.0, 349, 128),
    (9, 2, 1000.0, 340, 126),
    (9, 3, 1000.0, 345, 125),
    (9, 4, 1000.0, 363, 125),
    (9, 5, 1000.0, 356, 126);
-- activity 10: Sam, cycling 2026-09-13
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (10, 1, 5000.0, 766, 136),
    (10, 2, 5000.0, 817, 138),
    (10, 3, 5000.0, 781, 137),
    (10, 4, 5000.0, 796, 136),
    (10, 5, 5000.0, 781, 135);
-- activity 11: Sam, cycling 2026-09-30
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (11, 1, 5000.0, 792, 148),
    (11, 2, 5000.0, 753, 148),
    (11, 3, 5000.0, 748, 148),
    (11, 4, 5000.0, 790, 148),
    (11, 5, 5000.0, 773, 148),
    (11, 6, 5000.0, 744, 146),
    (11, 7, 5000.0, 745, 146),
    (11, 8, 5000.0, 793, 148);
-- activity 12: Sam, running 2026-10-17
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (12, 1, 1000.0, 277, 172),
    (12, 2, 1000.0, 277, 171),
    (12, 3, 1000.0, 283, 172),
    (12, 4, 1000.0, 297, 170),
    (12, 5, 1000.0, 294, 168),
    (12, 6, 1000.0, 292, 166),
    (12, 7, 1000.0, 292, 169),
    (12, 8, 1000.0, 298, 169),
    (12, 9, 1000.0, 297, 172),
    (12, 10, 1000.0, 282, 171);
-- activity 13: Riley, running 2026-09-02
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (13, 1, 1000.0, 322, 117),
    (13, 2, 1000.0, 331, 120),
    (13, 3, 1000.0, 317, 119),
    (13, 4, 1000.0, 327, 121),
    (13, 5, 1000.0, 328, 121);
-- activity 14: Riley, cycling 2026-09-09
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (14, 1, 5000.0, 630, 133),
    (14, 2, 5000.0, 653, 136),
    (14, 3, 5000.0, 626, 139),
    (14, 4, 5000.0, 644, 137),
    (14, 5, 5000.0, 637, 136),
    (14, 6, 5000.0, 609, 138),
    (14, 7, 5000.0, 622, 141),
    (14, 8, 5000.0, 607, 140);
-- activity 15: Riley, running 2026-09-13
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (15, 1, 1000.0, 310, 121),
    (15, 2, 1000.0, 313, 123),
    (15, 3, 1000.0, 305, 124),
    (15, 4, 1000.0, 326, 123),
    (15, 5, 1000.0, 329, 125),
    (15, 6, 1000.0, 321, 126);
-- activity 16: Riley, cycling 2026-10-12
INSERT INTO lap (activity_id, lap_number, distance_m, duration_sec, avg_hr) VALUES
    (16, 1, 5000.0, 634, 137),
    (16, 2, 5000.0, 629, 136),
    (16, 3, 5000.0, 647, 135),
    (16, 4, 5000.0, 616, 135),
    (16, 5, 5000.0, 634, 136),
    (16, 6, 5000.0, 608, 139),
    (16, 7, 5000.0, 635, 137),
    (16, 8, 5000.0, 626, 140),
    (16, 9, 5000.0, 643, 141);

-- event_registration
INSERT INTO event_registration (athlete_id, event_id, activity_id, registration_date, bib_number, finish_time_sec, overall_placement, status) VALUES
    (1, 1, 4, '2026-08-30', 412, 2754, 118, 'completed'),  -- Maya: Knoxville Fall 10K (completed)
    (3, 1, 12, '2026-09-02', 655, 2889, 203, 'completed'),  -- Sam: Knoxville Fall 10K (completed)
    (2, 2, NULL, '2026-10-15', NULL, NULL, NULL, 'registered'),  -- Jordan: Saturday Morning Group Ride (registered)
    (2, 3, NULL, '2026-09-20', NULL, NULL, NULL, 'registered'),  -- Jordan: Smoky Mountain Gran Fondo (registered)
    (4, 1, NULL, '2026-08-29', NULL, NULL, NULL, 'withdrawn'),  -- Riley: Knoxville Fall 10K (withdrawn)
    (4, 2, NULL, '2026-10-10', NULL, NULL, NULL, 'registered'),  -- Riley: Saturday Morning Group Ride (registered)
    (4, 3, NULL, '2026-10-01', NULL, NULL, NULL, 'registered');  -- Riley: Smoky Mountain Gran Fondo (registered)

COMMIT;
