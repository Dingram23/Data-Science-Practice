-- This public database is from http://2016.padjo.org/tutorials/sqlite-data-starterpacks/#toc-m3-0-earthquakes-in-the-contiguous-u-s-1995-through-2015
-- It pertains to earthquakes in the contiguous US of magnitude 3+ between 1995 and 2015
-- A glossary of terms can be found at https://earthquake.usgs.gov/data/comcat/data-eventterms.php

-- Queries are commented out with /* ... */ to avoid accidental running

-- 1. What different types of earthquakes were there, how many were there of each, and how did their magnitudes compare?

/*SELECT type,
    COUNT(*) AS num_quakes,
    MAX(mag) AS max_magnitude,
    MIN(mag) AS min_magnitude,
    ROUND(AVG(mag), 2) AS avg_magnitude
FROM quakes
GROUP BY 1
ORDER BY 2 DESC;*/

-- 2. How does the number of earthquakes and their magnitude relate to the depth of the epicenter?
-- Note depth is reported relative to sea level, hence negative depths are possible if the epicenter is above sea level

-- Depth range:

/*SELECT MIN(depth), 
    MAX(depth)
FROM quakes;*/

/*WITH depth_bins AS (
    SELECT id, 
        depth,
        mag,
        CASE
            WHEN depth BETWEEN -10 AND 0 THEN '-10 to 0'
            WHEN depth BETWEEN 0 AND 10 THEN '0 to 10'
            WHEN depth BETWEEN 10 AND 20 THEN '10 to 20'
            WHEN depth BETWEEN 20 AND 30 THEN '20 to 30'
            WHEN depth BETWEEN 30 AND 40 THEN '30 to 40'
            WHEN depth BETWEEN 40 AND 50 THEN '40 to 50'
            WHEN depth BETWEEN 50 AND 60 THEN '50 to 60'
            WHEN depth BETWEEN 60 AND 70 THEN '60 to 70'
            WHEN depth BETWEEN 70 AND 80 THEN '70 to 80'
            WHEN depth BETWEEN 80 AND 90 THEN '80 to 90'
            WHEN depth BETWEEN 90 AND 100 THEN '90 to 100'
            WHEN depth BETWEEN 100 AND 110 THEN '100 to 110'
            END AS depth_range
    FROM quakes
)

SELECT depth_range,
    COUNT(*) AS num_quakes,
    MIN(mag) AS min_mag, 
    MAX(mag) AS max_mag, 
    ROUND(AVG(mag), 2) AS avg_mag
FROM depth_bins
GROUP BY depth_range
ORDER BY 
    CASE depth_range
        WHEN '-10 to 0' THEN 0
        WHEN '0 to 10' THEN 1
        WHEN '10 to 20' THEN 2
        WHEN '20 to 30' THEN 3
        WHEN '30 to 40' THEN 4
        WHEN '40 to 50' THEN 5
        WHEN '50 to 60' THEN 6
        WHEN '60 to 70' THEN 7
        WHEN '70 to 80' THEN 8
        WHEN '80 to 90' THEN 9
        WHEN '90 to 100' THEN 10
        WHEN '100 to 110' THEN 11
    END;*/

 -- Note, the ORDER BY CASE used in the above query is certainly long-winded to write, just in order to deal with '100 to 110' appearing normally after '10 to 20' 
 -- This way does produce a cleaner output, hence why I used it, but a quicker and more concise way to code would have simply been to add an ordered prefix to the beginning of the depth_range strings like 'a. -10 to 0', 'b. 10 to 20' , 'c. 20 to 30' etc...

-- 3. The table has a 'place' column with varying details of earthquake epicenter location, can this be converted to solely which state it happened in?
-- Note have only added a CASE statement for the western-most states, as well as Oklahoma as it had a lot of quakes, this methodology could be continued for all 48 contiguous US states (+ however many from Mexico and Canada) 

-- Add padding of one space to start and end of every entry in 'place'
-- This makes it so that we can search with the LIKE clause for '% state_name %' OR '% state_abbrev %' and avoid problems where the state abbreviation can be part of a word, for example New York being misclassified as Oregon due to OR in York
-- Also note that the Gulf of California is a place not in California, so make sure to not include earthquakes there in California's total

/*WITH padded_place AS (
    SELECT place,
        mag,
        ' ' || place || ' ' AS pad_place
    FROM quakes
),

states AS (
    SELECT place,
        mag,
        CASE
            WHEN (pad_place NOT LIKE '% Gulf %') AND ((pad_place LIKE '% California %') OR (pad_place LIKE '% CA %')) THEN 'California'
            WHEN (pad_place LIKE '% Colorado %') OR (pad_place LIKE '% CO %') THEN 'Colorado'
            WHEN (pad_place LIKE '% Oregon %') OR (pad_place LIKE '% OR %') THEN 'Oregon'
            WHEN (pad_place LIKE '% Washington %') OR (pad_place LIKE '% WA %') THEN 'Washington'
            WHEN (pad_place LIKE '% Baja %') OR (pad_place LIKE '% B.C. %') OR (pad_place LIKE '% B.C., %')  THEN 'Baja California, Mexico'
            WHEN (pad_place LIKE '% Nevada %') OR (pad_place LIKE '% NV %') THEN 'Nevada'
            WHEN (pad_place LIKE '% Idaho %') OR (pad_place LIKE '% ID %') THEN 'Idaho'
            WHEN (pad_place LIKE '% Montana %') OR (pad_place LIKE '% MT %') THEN 'Montana'
            WHEN (pad_place LIKE '% Wyoming %') OR (pad_place LIKE '% WY %') THEN 'Wyoming'
            WHEN (pad_place LIKE '% Oklahoma %') OR (pad_place LIKE '% OK %') THEN 'Oklahoma'
            WHEN(pad_place LIKE '% Utah %') OR (pad_place LIKE '% UT %') THEN 'Utah'
            WHEN (pad_place LIKE '% Arizona %') OR (pad_place LIKE '% AZ %') THEN 'Arizona'
            WHEN (pad_place LIKE '% New Mexico %') OR (pad_place LIKE '% NM %') THEN 'New Mexico'
            ELSE 'Other'
            END AS state
    FROM padded_place
)

SELECT place, 
    state
FROM states
LIMIT 100;*/

-- 4. How does the magnitude and number of earthquakes vary based on state?
-- Using the temporary tables padded_place and states from 3.

/*WITH padded_place AS (
    SELECT place,
        mag,
        ' ' || place || ' ' AS pad_place
    FROM quakes
),

states AS (
    SELECT place,
        mag,
        CASE
            WHEN (pad_place NOT LIKE '% Gulf %') AND ((pad_place LIKE '% California %') OR (pad_place LIKE '% CA %')) THEN 'California'
            WHEN (pad_place LIKE '% Colorado %') OR (pad_place LIKE '% CO %') THEN 'Colorado'
            WHEN (pad_place LIKE '% Oregon %') OR (pad_place LIKE '% OR %') THEN 'Oregon'
            WHEN (pad_place LIKE '% Washington %') OR (pad_place LIKE '% WA %') THEN 'Washington'
            WHEN (pad_place LIKE '% Baja %') OR (pad_place LIKE '% B.C. %') OR (pad_place LIKE '% B.C., %')  THEN 'Baja California, Mexico'
            WHEN (pad_place LIKE '% Nevada %') OR (pad_place LIKE '% NV %') THEN 'Nevada'
            WHEN (pad_place LIKE '% Idaho %') OR (pad_place LIKE '% ID %') THEN 'Idaho'
            WHEN (pad_place LIKE '% Montana %') OR (pad_place LIKE '% MT %') THEN 'Montana'
            WHEN (pad_place LIKE '% Wyoming %') OR (pad_place LIKE '% WY %') THEN 'Wyoming'
            WHEN (pad_place LIKE '% Oklahoma %') OR (pad_place LIKE '% OK %') THEN 'Oklahoma'
            WHEN(pad_place LIKE '% Utah %') OR (pad_place LIKE '% UT %') THEN 'Utah'
            WHEN (pad_place LIKE '% Arizona %') OR (pad_place LIKE '% AZ %') THEN 'Arizona'
            WHEN (pad_place LIKE '% New Mexico %') OR (pad_place LIKE '% NM %') THEN 'New Mexico'
            ELSE 'Other'
            END AS state
    FROM padded_place
)

SELECT state,
    COUNT(*) AS num_quakes,
    ROUND(AVG(mag), 2) AS avg_mag,
    MIN(mag) AS min_mag,
    MAX(mag) AS max_mag
FROM states
GROUP BY 1
ORDER BY 2 DESC;*/

