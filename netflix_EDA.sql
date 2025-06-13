-- Netflix Project
DROP TABLE IF EXISTS netflixdata;

CREATE TABLE netflixdata
(
	show_id VARCHAR(6),
	type 	VARCHAR(10),
	title	VARCHAR(150),
	director VARCHAR(208),
	casts  	VARCHAR(1000),
	country	VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
	

);

SELECT * FROM netflixdata;

SELECT COUNT(*) as total_content
FROM netflixdata;

SELECT
	DISTINCT type
FROM netflixdata;

-- 15 Business problems
--1. Count the number of movies vs tv shows

SELECT
	type,
	COUNT(*) as total_content
FROM netflixdata
GROUP BY type;

2. Find the most common rating for movies and tv shows

SELECT
	type,
	rating
FROM

(SELECT
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*)) AS ranking
	--MAX(rating)
	FROM netflixdata
	GROUP BY 1,2
	) as t1
	WHERE ranking = 1;

3. List all the movies released in a specific year (e.g., 2020)

-- filter 2020
-- movies

SELECT
	*
	FROM netflixdata
	WHERE type = 'Movie'
	AND release_year = '2020';


4. Find the top 5 countries with the most content on Netflix


SELECT
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,    --Unnesting and spliting the data
	COUNT(show_id) AS total_content
FROM netflixdata
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;



		

5. Identify the longest movie or tv show duration

SELECT
	*
	FROM netflixdata
	WHERE type = 'Movie'
	AND duration = (SELECT MAX(duration) FROM netflixdata)
	



6. Find content added in the last 5 years

SELECT *, TO_DATE(date_added, 'Month DD, YYYY')
FROM netflixdata
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';



--SELECT CURRENT_DATE - INTERVAL '5 years'




7. Find all the movies/tv shows by director 'Rajiv Chilaka'!

SELECT
	*
	FROM netflixdata
	WHERE director ILIKE '%Rajiv Chilaka%';

8. List all tv shows with more than 5 seasons

SELECT
	*,
	SPLIT_PART(duration, ' ',1) AS sessions
	FROM netflixdata
	WHERE type = 'TV Show' AND
	SPLIT_PART(duration, ' ',1)::numeric > 5




9. Count the number of content items in each genre

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	count(show_id)
	FROM netflixdata
	GROUP BY 1;


10. Find the average release year for content produced in a specific country

SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
	COUNT(*),
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflixdata WHERE country = 'India')*100,2) as average_content_per_year
	
	FROM netflixdata
	WHERE country = 'India'
	GROUP BY 1;


11. List all movies that are documentaries

SELECT
	type,
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
	FROM netflixdata
	WHERE type = 'Movie'
	AND 

SELECT * FROM netflixdata
WHERE listed_in ILIKE '%documentaries%'

12. Find how many movies actor 'Salman Khan' appeared in last 10 years

SELECT
	type,
	UNNEST(STRING_TO_ARRAY(casts, ',')),
	COUNT(*)
FROM netflixdata
WHERE type ILIKE '%movie%'
AND TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '10 YEARS'
GROUP BY 1,2


SELECT
	*
	FROM netflixdata
	WHERE casts ILIKE '%Salman Khan%'
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10 


--SELECT CURRENT_DATE



13. Find all content without a director


SELECT
	* FROM netflixdata
	WHERE director IS NULL


14. Find the top 10 actors who have appeard in the highest number of movies produced in India.

SELECT
	UNNEST(STRING_TO_ARRAY(casts, ',')),
	COUNT(*),
	country
	FROM netflixdata
	WHERE country ILIKE '%India%'
	GROUP BY 1,3
	ORDER BY 2 DESC
	LIMIT 10

15. Categorize the content based on the presence of the keywords 'Kill' and 'violence'
in the description field. Label content containing these keywords as 'Bad' and all other
content as 'Good'. Count how many items fall into each category.

WITH new_table AS (
SELECT
	*,
	CASE WHEN 
		description ILIKE '%Kill%'
		OR description ILIKE '%violence%' THEN 'Bad_Content'
		ELSE 'Good Content'
	END AS category
		FROM netflixdata
)

SELECT
	category,
	COUNT(*)
FROM new_table
GROUP BY 1
