-- ************************************** Netflix Data Analyst project on MySQL ******************************
drop database if exists Netflixs_movies;
create database Netflixs_movies;
use Netflixs_movies;

drop table if exists netflixs;
create table netflixs
(
	show_id varchar(6),
	type varchar(10),
	title varchar(150),
	director varchar(210),
	casts varchar(1000),
	country	varchar(150),
	date_added varchar(50),
	release_year int,
	rating	varchar(10),
	duration varchar(15),	
	listed_in varchar(100),
	description varchar(300)
);

show columns from netflixs;

select * from netflixs;

select 
	count(*) as total_content
from netflixs;

select 
	*
from netflixs;

select 
	distinct type
from netflixs;

-- ***************************************** 15 Business problems & Solutions*******************************

-- 1. count the number of movies vs TV shows.
select 
	type,
    count(*) as total_content
from netflixs
group by type;

-- 2. Find the most common rating for movies and TV shows.
select 
	type,
    rating
from 
(
	select 
		type,
		rating,
		count(*),
		rank() over(partition by type order by count(*)) as ranking
	from netflixs
	group by 1,2
) as t1
where 
	ranking=1;

-- 3. list all movies released in a specific year(e.g., 2020).
select * from netflixs
where 
	type='Movie'
    and
    release_year = 2020;

-- 4. find the top 5 countries with the most content on netflix.
SELECT 
	country,
	COUNT(show_id) AS total_content
FROM netflixs
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Indentify the longest movies or TV show duration. 
SELECT *
FROM netflixs
WHERE duration = (
	SELECT MAX(duration)
	FROM netflixs
	WHERE duration REGEXP 'min|Season'
);

-- and 2nd option
SELECT *
FROM netflixs
ORDER BY 
	CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;
 
-- 6. find content added in the last 5 years
SELECT *
FROM netflixs
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);

-- 7. list all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM netflixs
WHERE director LIKE '%Andy Devonshire%';

-- 8. list all tv shows which more than 5 seasons
SELECT *
FROM netflixs
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

-- 9. count the number of content items in each genre
SELECT 
	listed_in AS genre,
	COUNT(*) AS total_content
FROM netflixs
GROUP BY listed_in
ORDER BY total_content DESC;

-- 10. find the average release year of content produced in last 10 years!
SELECT 
	ROUND(AVG(release_year), 2) AS avg_release_year
FROM netflixs
WHERE release_year >= YEAR(CURDATE()) - 10;

-- 11. list all movies that are documentaries
SELECT *
FROM netflixs
WHERE type = 'Movie'
  AND listed_in LIKE '%Documentaries%';

-- 12. find all content without a director
SELECT *
FROM netflixs
WHERE director IS NULL OR director = '';

-- 13. find how many movies actor 'salman khan' appeared in last 10 years!
SELECT 
	COUNT(*) AS total_movies
FROM netflixs
WHERE type = 'Movie'
  AND casts LIKE '%Gary Oldman%'
  AND release_year >= YEAR(CURDATE()) - 10;

-- 14. find the top 10 actors who have appeared in the highest number of movies produced in india
SELECT 
	actor AS actor_name,
	COUNT(*) AS total_movies
FROM (
	SELECT 
		TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(casts, ',', n.n), ',', -1)) AS actor,
		show_id
	FROM netflixs
	JOIN (
		SELECT a.N + b.N * 10 + 1 AS n
		FROM 
			(SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
			 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
			(SELECT 0 AS N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
			 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) b
	) AS n
	WHERE n.n <= 1 + LENGTH(casts) - LENGTH(REPLACE(casts, ',', ''))
) AS actors_split
JOIN netflixs AS n2 USING (show_id)
WHERE 
	n2.type = 'Movie'
	AND n2.country LIKE '%India%'
	AND actor IS NOT NULL
	AND actor <> ''
GROUP BY actor_name
ORDER BY total_movies DESC
LIMIT 10;

-- 15. categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field.
-- Label content containing these keywords as 'Bad' and all other content as 'Good'. count how many items fall into 
-- each cotegory 
SELECT 
	CASE
		WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
		ELSE 'Good'
	END AS content_category,
	COUNT(*) AS total_content
FROM netflixs
GROUP BY content_category;

-- *************************************************** End Project ******************************************************