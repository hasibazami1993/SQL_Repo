--1. 1. Count the Number of Movies vs TV Shows

SELECT
	COUNT(type)
	FROM netflix;

--2. 2. Find the Most Common Rating for Movies and TV Shows

SELECT
	type,
	rating
FROM 
(SELECT
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as rank1
FROM netflix
GROUP BY 1,2
ORDER BY 1,3 DESC
) as t1
WHERE rank1 = 1

--3. 3. List All Movies Released in a Specific Year (e.g., 2020)

SELECT 
*
FROM netflix
WHERE type = 'Movie' AND
release_year = 2020;

--4. Find the top 5 countries with the most content on netflix

SELECT
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	COUNT(show_id) as total_content,
	RANK() OVER(PARTITION BY UNNEST(STRING_TO_ARRAY(country, ',')) ORDER BY COUNT(show_id)) as rank
	FROM netflix
	GROUP BY 1
	ORDER BY 2 DESC;	


--5. Identify the longest movie
SELECT
	*
	FROM netflix
	WHERE type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix)

--6. Find content added in the last 5 years

SELECT
	*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 YEARS'

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT
	*
	FROM netflix
	WHERE director ILIKE '%Rajiv Chilaka%';

--8. List all tv shows with more than 5 seasons

SELECT
	* FROM netflix
	WHERE type = 'TV Show'
	AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5;

--9. Count the number of content items in each genre

WITH cte AS (
	SELECT
		UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
		COUNT(*) as total
	FROM netflix
	GROUP BY 1
)

SELECT
	genre,
	total
FROM cte
GROUP BY 1,2
ORDER BY 2 DESC

--10. Find each year and the average numbers of content release in India on netflix.

SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as date,
	COUNT(*),
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric,2) * 100 as average_content
	FROM netflix
	WHERE country = 'India'
	GROUP BY 1;

--11.  List All Movies that are Documentaries

SELECT * FROM netflix
WHERE listed_in ILIKE '%documentaries%'

--12. Find All Content Without a Director
SELECT
	* FROM netflix
	WHERE director IS NULL

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT
	*
	FROM netflix
	WHERE casts ILIKE '%Salman Khan%'
	AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT
	--show_id,
	--casts,
	UNNEST(STRING_TO_ARRAY(casts, ',')),
	COUNT(*) as total_content
	FROM netflix
	WHERE country ILIKE '%India%'
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 10;

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;