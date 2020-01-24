-- This public database was obtained from http://2016.padjo.org/tutorials/sqlite-data-starterpacks/#toc-san-francisco-restaurant-health-inspections
-- It pertains to restaurant health inspections in San Francisco

-- NOTE: queries are commented out with /* ... */ to prevent accidental running

-- 1. What time range does the database cover?
-- Note the date is stored in the format 'YYYYMMDD' which is not a valid SQLite date format (e.g. 'YYYY-MM-DD') -  will first add a new column with it in proper format:

/*ALTER TABLE violations
ADD COLUMN date_formatted TEXT;*/

/*UPDATE violations
SET date_formatted =  SUBSTR(date, 1, 4) || '-' || SUBSTR(date, 5, 2) || '-' || SUBSTR(date, 7, 2);*/

-- Test (successful):

/*SELECT date, 
    date_formatted
FROM violations
LIMIT 100;*/

-- Time range:

/*SELECT MIN(date_formatted) AS start_date,
    MAX(date_formatted) AS end_date
FROM violations;*/

-- 2. Which restaurants in San Francisco have never had a health violation (in the date range covered by this data?)

/*SELECT business_id, 
    name
FROM businesses
WHERE business_id NOT IN (
    SELECT DISTINCT business_id
    FROM violations
);*/

-- 3. Which restaurants have the highest number of violations?

/*SELECT business_id, 
    name,
    COUNT(*) AS violations
FROM violations
LEFT JOIN businesses
    ON violations.business_id = businesses.business_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 100;*/

-- The restaurant with the highest number of violations had 42 in a 3 year period!

-- 4. Are the restaurants with the most reported violations still open because their violations are mainly considered lower risk?
-- Count number of each violations of each risk_category, then compare low risk to high risk ratio

/*SELECT business_id,
    name,
    COUNT(*) AS total_violations,
    SUM(risk_category LIKE 'Low%') AS low_risk,
    SUM(risk_category LIKE 'Moderate%') AS moderate_risk,
    SUM(risk_category LIKE 'High%') AS high_risk,
    ROUND(1.0 * SUM(risk_category LIKE 'Low%') / SUM(risk_category LIKE 'High%'), 2) AS LtH_ratio
FROM violations
JOIN businesses
    ON violations.business_id = businesses.business_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 100;*/

-- A quick scroll through the top 100 restaurants for number of health violations shows that most LtH (low-to-high) ratios are much greater than one - i.e. most of their violations are indeed considered low risk

-- 5. Of the restaurants with the highest numbers of violations, how many violations did they get per year?

/*SELECT business_id,
    COUNT(*) AS total_violations,
    SUM(date_formatted LIKE '2013%') AS viol_2013,
    SUM(date_formatted LIKE '2014%') AS viol_2014,
    SUM(date_formatted LIKE '2015%') AS viol_2015,
    SUM(date_formatted LIKE '2016%') AS viol_2016
FROM violations
GROUP BY 1
ORDER BY 2 DESC
LIMIT 100;*/

-- 6. Which previously high-violating restaurants no longer violate (up to the end of the date range)?

/*SELECT business_id,
    COUNT(*) AS total_violations,
    SUM(date_formatted LIKE '2013%') AS viol_2013,
    SUM(date_formatted LIKE '2014%') AS viol_2014,
    SUM(date_formatted LIKE '2015%') AS viol_2015,
    SUM(date_formatted LIKE '2016%') AS viol_2016
FROM violations
GROUP BY 1
HAVING viol_2016 = 0
ORDER BY 2 DESC
LIMIT 100;*/

-- 7. What are the postal codes with the highest numbers of health violations, does this correlate with the number of restaurants there?

/*SELECT postal_code,
    COUNT(*) AS no_violations,
    COUNT(DISTINCT businesses.business_id) AS no_restaurants,
    ROUND(1.0 * COUNT(*) / COUNT(DISTINCT businesses.business_id), 2) AS viol_per_rest
FROM businesses
LEFT JOIN violations
    ON businesses.business_id = violations.business_id
GROUP BY 1
HAVING postal_code NOT NULL
ORDER BY 2 DESC;*/
 
-- 8. How many unscheduled visitations discovered violations compared to scheduled?
-- Going by business_id and date due to lack of an ID for inspections

/*WITH unscheduled AS (
SELECT *
FROM inspections
JOIN violations
    ON inspections.business_id = violations.business_id
    AND inspections.date = violations.date
WHERE type = 'Routine - Unscheduled'
),

scheduled AS (
SELECT *
FROM inspections
JOIN violations
    ON inspections.business_id = violations.business_id
    AND inspections.date = violations.date
WHERE type = 'Routine - Scheduled'
)

SELECT COUNT(*) AS num_violations, 
    ROUND(1.0 * COUNT(*) / (SELECT COUNT(*) 
                              FROM inspections
                              WHERE type = 'Routine - Unscheduled'), 2) AS pct_inspections,
    'unscheduled' AS visit_type
FROM unscheduled
UNION ALL
SELECT COUNT(*),
    ROUND(1.0 * COUNT(*) / (SELECT COUNT(*) 
                              FROM inspections
                              WHERE type = 'Routine - Scheduled'), 2) AS pct_inspections, 
    'scheduled'
FROM scheduled;*/

-- 9. Which inspections did not discover any violations?

/*WITH concat_inspect AS (
    SELECT business_id || '-' || date AS concat
    FROM inspections
    ),
    
passed_inspect AS (
SELECT concat
FROM concat_inspect
WHERE concat NOT IN (
    SELECT DISTINCT business_id || '-' || date
    FROM violations
    )
)

SELECT SUBSTR(concat, 1, pos - 1) AS business_id,
       SUBSTR(concat, pos + 1) AS date
FROM  (SELECT *,
                     INSTR(concat, '-') AS pos
                FROM passed_inspect)
LIMIT 100;*/


