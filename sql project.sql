use netflix_db;
DROP TABLE IF EXISTS netflix_titles;

CREATE TABLE netflix_titles (
    show_id      VARCHAR(20),
    type         VARCHAR(20),
    title        VARCHAR(255),
    director     TEXT,
    cast         TEXT,
    country      VARCHAR(100),
    date_added   VARCHAR(50),
    release_year INT,
    rating       VARCHAR(10),
    duration     VARCHAR(20),
    listed_in    TEXT,
    description  TEXT
);

select count(*) as c 
from
 netflix_titles;
 select distinct type from netflix_titles;
 -- Business Problems and Solutions
-- 1. Count the Number of Movies vs TV Shows
select 
type ,count(*) as typecount from netflix_titles 
group by type; 

 -- 2. Find the Most Common Rating for Movies and TV Shows
SELECT 
    type,
    rating AS most_frequent_rating
FROM (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix_titles
    GROUP BY type, rating
) AS RankedRatings
WHERE rnk = 1; 
-- 3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT * 
FROM netflix_titles
WHERE release_year = 2020;
-- 4. Find the Top 5 Countries with the Most Content on Netflix
WITH RECURSIVE country_split AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(country, ',', 1)) AS country,
        SUBSTRING_INDEX(country, ',', -1) AS rest,
        1 AS part_number
    FROM netflix_titles
    WHERE country IS NOT NULL

    UNION ALL

    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS country,
        SUBSTRING_INDEX(rest, ',', -1),
        part_number + 1
    FROM country_split
    WHERE rest LIKE '%,%'
)
SELECT 
    country,
    COUNT(*) AS total_content
FROM country_split
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify the Longest Movie
SELECT * 
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;
 -- 6. Find Content Added in the Last 5 Years
 SELECT *
FROM netflix_titles
WHERE STR_TO_DATE(date_added, '%d %M, %Y') >= CURDATE() - INTERVAL 5 YEAR;
-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT *
FROM netflix_titles
WHERE FIND_IN_SET('Rajiv Chilaka', director) > 0;
-- 8. List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix_titles
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
-- 9. Count the Number of Content Items in Each Genre 
WITH RECURSIVE genre_split AS (
    SELECT
        TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
        SUBSTRING(listed_in, LENGTH(SUBSTRING_INDEX(listed_in, ',', 1)) + 2) AS rest
    FROM netflix_titles

    UNION ALL

    SELECT
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS genre,
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
    FROM genre_split
    WHERE rest != ''
)

SELECT
    genre,
    COUNT(*) AS total_content
FROM genre_split
GROUP BY genre
ORDER BY total_content DESC;
-- 10.Find each year and the average numbers of content release in India on netflix.
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) / 
        (SELECT COUNT(show_id) FROM netflix_titles WHERE country = 'India') * 100, 2
    ) AS avg_release
FROM netflix_titles
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;
-- 11. List All Movies that are Documentaries 
SELECT * 
FROM netflix_titles
WHERE listed_in LIKE '%Documentaries';
-- 12. Find All Content Without a Director

SELECT * 
FROM netflix_titles
WHERE director IS NULL OR TRIM(director) = '';
-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * 
FROM netflix_titles
WHERE cast LIKE '%Salman Khan%'
  AND release_year > YEAR(CURDATE()) - 10;
-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
WITH RECURSIVE cast_split AS (
    SELECT
        TRIM(SUBSTRING_INDEX(cast, ',', 1)) AS actor,
        SUBSTRING(cast, LENGTH(SUBSTRING_INDEX(cast, ',', 1)) + 2) AS rest
    FROM netflix_titles
    WHERE country = 'India' AND cast IS NOT NULL

    UNION ALL

    SELECT
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS actor,
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
    FROM cast_split
    WHERE rest != ''
) 

SELECT
    actor,
    COUNT(*) AS appearances
FROM cast_split
GROUP BY actor
ORDER BY appearances DESC
LIMIT 10;
-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix_titles
    WHERE description IS NOT NULL
) AS categorized_content
GROUP BY category;















