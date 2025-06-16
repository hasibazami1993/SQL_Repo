--Retrieve the names of all tracks that have more than 1 billion streams.
SELECT
	* FROM spotify
	WHERE stream > 1000000000;


--List all albums along with their respective artists.
SELECT
	 DISTINCT album FROM spotify
	 ORDER BY 1
	;

--Get the total number of comments for tracks where licensed = TRUE.
SELECT
	SUM(comments) 
	FROM spotify
	WHERE licensed = 'TRUE';

--Find all tracks that belong to the album type single.
SELECT
	track,
	album
FROM spotify
WHERE album_type ILIKE 'single';

--Count the total number of tracks by each artist.
SELECT
	track,
	COUNT(*)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;


--Calculate the average danceability of tracks in each album.
SELECT 
album,
AVG(danceability)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;



--Find the top 5 tracks with the highest energy values.
SELECT
	track,
	energy
FROM spotify
ORDER BY 2 DESC
LIMIT 5;

--List all tracks along with their total views and likes where official_video = TRUE.
SELECT
	track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 'TRUE'
GROUP BY 1
ORDER BY 2 DESC;

--For each album, calculate the total views of all associated tracks.
SELECT
	album,
	track,
	SUM(views)
FROM spotify
GROUP BY 1,2
ORDER BY 1,2 DESC;

--Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT
	* FROM 
(SELECT 
track,
--most_played_on,
COALESCE(SUM(CASE
	WHEN most_played_on = 'Spotify' THEN stream END),0) AS streamed_on_spotify,
COALESCE(SUM(CASE
	WHEN most_played_on = 'Youtube' THEN stream END),0) AS streamed_on_youtube
FROM spotify
GROUP BY 1
) as t1
WHERE streamed_on_spotify > streamed_on_youtube
AND streamed_on_youtube <> 0;



--Find the top 3 most-viewed tracks for each artist using window functions.

WITH ranking_artist AS (
SELECT
	artist,
	track,
	SUM(views) AS total_view,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
FROM spotify
GROUP BY 1,2
ORDER BY 1,3 DESC
)
SELECT * FROM ranking_artist
WHERE rank <= 3;


--Write a query to find tracks where the liveness score is above the average.

SELECT
	track,
	artist,
	liveness
	FROM spotify WHERE liveness > (
SELECT
	AVG(liveness)
	FROM spotify
);


--Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH cte
AS
(SELECT
	album,
	MAX(energy) AS highest_energy,
	MIN(energy) AS lowest_energy
FROM spotify
GROUP BY 1)
SELECT
	album,
	highest_energy - lowest_energy as energy_diff
FROM cte
ORDER BY 2 DESC;