-- Ride & Run Tracker: queries
--
PRAGMA foreign_keys = ON;


-- Requirement 1: Filtering and Sorting
-- Which long rides (40 km or more) have been logged from longest to shortest?
-- Shows the climbing and heart rate of each so the biggest training days stand out.
SELECT activity_id,
       start_time                           AS ride_start,
       ROUND(distance_m / 1000.0, 1)        AS distance_km,
       ROUND(duration_sec / 3600.0, 2)      AS duration_hr,
       ROUND(avg_speed_mps * 3.6, 1)        AS avg_speed_kmh,
       elevation_gain_m                     AS climbing_m,
       avg_hr
FROM activity
WHERE sport = 'cycling'
  AND distance_m >= 40000
ORDER BY distance_m DESC, start_time;


-- Requirement 2: INNER JOIN
-- What is each athletes activity log shown in the athlete's own preferred units?
-- Joins activity to athlete so every row has a name and the distance is in miles
-- or kilometers depending on athlete.preferred_units.
SELECT a.first_name || ' ' || a.last_name   AS athlete,
       ac.start_time                        AS activity_start,
       ac.sport,
       ROUND(ac.distance_m /
             CASE a.preferred_units WHEN 'mi' THEN 1609.344 ELSE 1000.0 END, 2)
                                            AS distance,
       a.preferred_units                    AS unit,
       ROUND(ac.duration_sec / 60.0, 1)     AS duration_min,
       ac.avg_hr
FROM activity ac
INNER JOIN athlete a ON a.athlete_id = ac.athlete_id
ORDER BY athlete, ac.start_time;


-- Requirement 3: LEFT JOIN
-- Which gear has been used, how often, and when was it last used?
-- LEFT JOIN keeps every piece of gear including gear with no activities at all
--  which an inner join would drop.
SELECT a.first_name || ' ' || a.last_name           AS athlete,
       g.name                                       AS gear_name,
       g.gear_type,
       g.is_retired,
       COUNT(ac.activity_id)                        AS times_used,
       COALESCE(MAX(ac.start_time), 'never used')   AS last_used
FROM gear g
INNER JOIN athlete a       ON a.athlete_id = g.athlete_id
LEFT JOIN  activity ac     ON ac.gear_id   = g.gear_id
GROUP BY g.gear_id
ORDER BY times_used, athlete, gear_name;


-- Requirement 4: Three-Table Join  (supports the event / race results report)
-- Who is registered for which event, and how did the completed ones go?
-- Joins event_registration, athlete and event, plus a LEFT JOIN to the result
-- activity so registrations with no result (not yet raced, or withdrawn) still show.
SELECT e.event_date,
       e.name                                       AS event_name,
       a.first_name || ' ' || a.last_name           AS athlete,
       r.status                                     AS registration_status,
       r.bib_number,
       r.overall_placement                          AS placement,
       CASE WHEN r.finish_time_sec IS NULL THEN NULL
            ELSE printf('%d:%02d:%02d', r.finish_time_sec / 3600,
                        (r.finish_time_sec % 3600) / 60, r.finish_time_sec % 60)
       END                                          AS finish_time,
       CASE WHEN r.finish_time_sec IS NULL THEN NULL
            ELSE ROUND(r.finish_time_sec / 60.0 / (e.distance_m / 1000.0), 2)
       END                                          AS pace_min_per_km,
       ac.avg_hr                                    AS race_avg_hr
FROM event_registration r
INNER JOIN athlete a       ON a.athlete_id  = r.athlete_id
INNER JOIN event e         ON e.event_id    = r.event_id
LEFT JOIN  activity ac     ON ac.activity_id = r.activity_id
ORDER BY e.event_date, r.overall_placement IS NULL, r.overall_placement, athlete;


-- Requirement 5: Aggregate Query
-- What do the running totals look like across all athletes?
-- Uses COUNT, SUM, AVG, MAX and MIN over every logged run.
SELECT COUNT(*)                                     AS total_runs,
       ROUND(SUM(distance_m) / 1000.0, 1)           AS total_km,
       ROUND(AVG(distance_m) / 1000.0, 2)           AS avg_run_km,
       ROUND(MAX(distance_m) / 1000.0, 1)           AS longest_run_km,
       ROUND(AVG(avg_hr), 0)                        AS avg_heart_rate,
       MIN(start_time)                              AS first_run,
       MAX(start_time)                              AS latest_run
FROM activity
WHERE sport = 'running';


-- Requirement 6: GROUP BY and HAVING  (supports the HR zone 2 pace report)
-- How is each athlete's easy-effort (zone 2) running pace changing week to week?
-- Laps whose average heart rate falls inside the athlete's own zone 2 range are
-- grouped by athlete and week. HAVING keeps only weeks with at least 6 km of
-- zone 2 running, because a week with less is too small to compare pace fairly.
SELECT a.first_name || ' ' || a.last_name           AS athlete,
       strftime('%Y-W%W', ac.start_time)            AS training_week,
       COUNT(*)                                     AS zone2_laps,
       ROUND(SUM(l.distance_m) / 1000.0, 1)         AS zone2_km,
       ROUND(SUM(l.duration_sec) / 60.0 / (SUM(l.distance_m) / 1000.0), 2)
                                                    AS avg_pace_min_per_km
FROM lap l
INNER JOIN activity ac     ON ac.activity_id = l.activity_id
INNER JOIN athlete a       ON a.athlete_id   = ac.athlete_id
INNER JOIN hr_zone z       ON z.athlete_id   = a.athlete_id
                          AND z.zone_number  = 2
                          AND l.avg_hr BETWEEN z.min_bpm AND z.max_bpm
WHERE ac.sport = 'running'
GROUP BY a.athlete_id, training_week
HAVING SUM(l.distance_m) >= 6000
ORDER BY athlete, training_week;


-- Requirement 7: Subquery  (supports the goal progress report)
-- How far along is each distance goal?
-- Goal progress is not stored. It is calculated from the activities inside the
-- goal's date range and sport. The correlated subquery totals those activities
-- for each goal (a goal with no sport counts both sports), and the outer query
-- turns the total into a percent of the target.
SELECT athlete,
       sport,
       goal_period,
       target_km,
       logged_km,
       ROUND(100.0 * logged_km / target_km, 1)      AS percent_complete,
       status
FROM (
    SELECT a.first_name || ' ' || a.last_name       AS athlete,
           COALESCE(g.sport, 'any sport')           AS sport,
           g.start_date || ' to ' || g.end_date     AS goal_period,
           g.target_value                           AS target_km,
           ROUND(COALESCE((SELECT SUM(ac.distance_m)
                           FROM activity ac
                           WHERE ac.athlete_id = g.athlete_id
                             AND (g.sport IS NULL OR ac.sport = g.sport)
                             AND date(ac.start_time) BETWEEN g.start_date AND g.end_date),
                          0) / 1000.0, 1)           AS logged_km,
           g.status
    FROM goal g
    INNER JOIN athlete a ON a.athlete_id = g.athlete_id
    WHERE g.goal_type = 'distance'
      AND g.target_unit = 'km'
)
ORDER BY percent_complete DESC;


-- Requirement 8: Set Operation (EXCEPT)
-- Which athletes have registered for events but have never completed one?
-- The first SELECT is everyone with a registration. EXCEPT removes the athletes
-- with a completed registration. The remaining athletes are the ones to follow up
-- with (upcoming events or a withdrawal).
SELECT a.athlete_id,
       a.first_name || ' ' || a.last_name           AS athlete
FROM athlete a
INNER JOIN event_registration r ON r.athlete_id = a.athlete_id
EXCEPT
SELECT a.athlete_id,
       a.first_name || ' ' || a.last_name
FROM athlete a
INNER JOIN event_registration r ON r.athlete_id = a.athlete_id
WHERE r.status = 'completed'
ORDER BY athlete;


-- Requirement 9: View  (supports the gear mileage report)
-- Which active gear is closest to its retirement threshold?
-- The gear_mileage view already joins gear athlete and activity and totals the
-- distance, so this query is a simple filter and sort instead of repeating that
-- join and aggregation. Gear with no threshold (bikes) and retired gear is excluded.
SELECT athlete_name,
       gear_name,
       gear_type,
       activity_count,
       ROUND(total_distance_m / 1000.0, 1)                          AS total_km,
       ROUND((retirement_threshold_m - total_distance_m) / 1000.0, 1) AS km_remaining,
       pct_of_threshold                                             AS percent_used,
       due_for_retirement
FROM gear_mileage
WHERE is_retired = 0
  AND retirement_threshold_m IS NOT NULL
ORDER BY pct_of_threshold DESC;
