-- Public database from http://2016.padjo.org/tutorials/sqlite-data-starterpacks/#more-info-dallas-police-officer-involved-shootings
-- It pertains to information on incidents in Dallas involving a police officer and shootings

-- Queries are commented out with /* ... */ to prevent accidental running

-- This database has no separate ID for subjects, meaning we can't tell if people re-offended
-- Some full_names are repeated, but that doesn't necessarily mean the subjects are the same people!

-- 1. Clean the data - some entries for name have not been sorted correctly into first/last/full
-- Identify entries that need to be cleaned:

/*SELECT *
FROM subjects
WHERE first_name IS NULL
AND full_name IS NOT 'Unknown';*/

/*SELECT *
FROM officers
WHERE first_name IS NULL;*/

-- Fix the names
/*UPDATE subjects
SET first_name = 'Keliam', last_name = 'Rudd', full_name = 'Rudd, Keliam'
WHERE full_name = 'Keliam Rudd';*/

/*UPDATE subjects
SET first_name = 'Dontrell', last_name = 'Terrell', full_name = 'Terrell, Dontrell'
WHERE full_name = 'Dontrell Terrell'*/

/*UPDATE officers
SET first_name = 'Rebecca', last_name = 'Barrios', full_name = 'Barrios, Rebecca'
WHERE full_name = 'Rebecca Barrios';*/

/*UPDATE officers
SET first_name = 'Eduardo', last_name = 'Oliveros', full_name = 'Oliveros, Eduardo'
WHERE full_name = 'Eduardo Oliveros';*/

-- 2. How does the number of officers attending an incident affect the outcome?

-- Will be considering subject_statuses as the 'outcome' of the incident
-- Note that this is not necessarily the status of the subject (confusingly so) but rather a general sum-up of the total number of injured/deceased, not including the officers
-- This can be seen from reading the summary_text from specific cases, e.g. case_number 738862R, listed as 1 subject, but 2 injured - neither of who were the subject with the gun

-- Find all the types of outcomes:

/*SELECT DISTINCT subject_statuses
FROM incidents;*/

-- The 'Deceased  Injured' entry was also 1 deceased, 1 injured from reading the specific case entry

/*SELECT *
FROM incidents
WHERE subject_statuses = 'Deceased Injured';*/

-- Count the number of incidents, grouped by officer_count and outcome:

/*WITH inc_count AS (
    SELECT officer_count,
        COUNT(*) AS num_inc
    FROM incidents
    GROUP BY 1
)

SELECT officer_count,
    subject_statuses AS outcome,
    COUNT(*) AS num_incidents,
    ROUND(100.0 * COUNT(*) / (
        SELECT num_inc 
        FROM inc_count
        WHERE incidents.officer_count = inc_count.officer_count)
    , 2) AS pct_incidents_per_officer_count
FROM incidents
GROUP BY 1, 2
ORDER BY 1, 4 DESC;*/

-- 3. How does the number of subjects affect the outcome?

/*WITH inc_count AS (
    SELECT subject_count,
        COUNT(*) AS num_inc
    FROM incidents
    GROUP BY 1
)

SELECT subject_count,
    subject_statuses AS outcome,
    COUNT(*) AS num_incidents,
    ROUND(100.0 * COUNT(*) / (
        SELECT num_inc 
        FROM inc_count
        WHERE incidents.subject_count = inc_count.subject_count)
    , 2) AS pct_incidents_per_subject_count
FROM incidents
GROUP BY 1, 2
ORDER BY 1, 4 DESC;*/

-- 4. How does the subject's weapon affect the outcome?

/*WITH inc_count AS (
    SELECT subject_weapon,
        COUNT(*) AS num_inc
    FROM incidents
    GROUP BY 1
)

SELECT subject_weapon,
    subject_statuses AS outcome,
    COUNT(*) AS num_incidents,
    ROUND(100.0 * COUNT(*) / (
        SELECT num_inc 
        FROM inc_count
        WHERE incidents.subject_weapon = inc_count.subject_weapon)
    , 2) AS pct_incidents_per_subject_weapon
FROM incidents
GROUP BY 1, 2
ORDER BY 1, 4 DESC;*/

-- 5. What are the incident outcomes depending on subject ethnicity and gender?

/*WITH inc_count AS (
    SELECT subject_statuses,
        race,
        gender,
        COUNT(*) AS inc_num
    FROM incidents
    JOIN subjects
        ON incidents.case_number = subjects.case_number
    GROUP BY 2, 3
)

SELECT race,
    gender,
    subject_statuses AS outcome,
    COUNT(*) AS num_incidents,
    ROUND(100.0 * COUNT(*) / (
        SELECT inc_num
        FROM inc_count
        WHERE subjects.race = inc_count.race
        AND subjects.gender = inc_count.gender)
    , 2) AS pct_incidents_per_subject_race_gender
FROM incidents
JOIN subjects
    ON incidents.case_number = subjects.case_number
GROUP BY 1, 2, 3
ORDER BY 1, 2, 5 DESC;*/

-- 6. What are the incident outcomes depending on officer ethnicity and gender?

/*WITH inc_count AS (
    SELECT subject_statuses,
        race,
        gender,
        COUNT(*) AS inc_num
    FROM incidents
    JOIN officers
        ON incidents.case_number = officers.case_number
    GROUP BY 2, 3
)

SELECT race,
    gender,
    subject_statuses AS outcome,
    COUNT(*) AS num_incidents,
    ROUND(100.0 * COUNT(*) / (
        SELECT inc_num
        FROM inc_count
        WHERE officers.race = inc_count.race
        AND officers.gender = inc_count.gender)
    , 2) AS pct_incidents_per_officer_race_gender
FROM incidents
JOIN officers
    ON incidents.case_number = officers.case_number
GROUP BY 1, 2, 3
HAVING race NOT NULL
ORDER BY 1, 2, 5 DESC;*/

-- 7. Do incidents involving officers of certain ethnicities with subjects of specific ethnicities tend to have different outcomes?

/*WITH inc_count AS (
    SELECT subject_statuses,
        officers.race AS o_race,
        officers.gender AS o_gender,
        subjects.race AS s_race,
        subjects.gender AS s_gender,
        COUNT(*) AS inc_num
    FROM incidents
    JOIN officers
        ON incidents.case_number = officers.case_number
    JOIN subjects
        ON incidents.case_number = subjects.case_number
    GROUP BY 2, 3, 4, 5
    HAVING o_race NOT NULL
)

SELECT officers.race AS o_race,
    officers.gender AS o_gender,
    subjects.race AS s_race,
    subjects.gender AS s_gender,
    subject_statuses AS outcome,
    COUNT(*) AS num_incidents,
    ROUND(100.0 * COUNT(*) / (
        SELECT inc_num
        FROM inc_count
        WHERE officers.race = inc_count.o_race
        AND officers.gender = inc_count.o_gender
        AND subjects.race = inc_count.s_race
        AND subjects.gender = inc_count.s_gender)
    , 2) AS pct_incidents_per_officer_subject_race_gender
FROM incidents
JOIN officers
    ON incidents.case_number = officers.case_number
JOIN subjects
    ON incidents.case_number = subjects.case_number
GROUP BY 1, 2, 3, 4, 5
HAVING o_race NOT NULL
ORDER BY 1, 2, 3, 4, 7 DESC;*/

-- 8. Has the number of incidents, or type (weapon) of incident, changed with time?

/*SELECT STRFTIME('%Y', date) AS year,
    subject_weapon,
    COUNT(*) AS  num_incidents
FROM incidents
GROUP BY 1, 2
ORDER BY 1, 3 DESC;*/