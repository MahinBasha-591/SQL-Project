--- NETFLIX PROJECT ---
 
--- Create Table ---

CREATE TABLE Netflix 
(
  Show_id VARCHAR(7),
  Content_Type VARCHAR(7),
  Title VARCHAR(160),
  Director VARCHAR(215),
  Casts VARCHAR(1100),
  Country VARCHAR(160),
  Date 	VARCHAR(60),
  Release_Year VARCHAR(15),
  Rating VARCHAR(15),
  Duration VARCHAR(20),
  Genres VARCHAR(300),
  Description VARCHAR(260)
);


--- Details of Table ---

SELECT * FROM netflix_titles;

--- No. of Data present in Table---

SELECT COUNT(*) FROM netflix_titles;


--- Business Questions ---

-- 1. Count No. of Movies and TV Shows

SELECT type, COUNT(*) FROM netflix_titles
GROUP BY type;


-- 2. Find the most common rating for Movies and TV Shows 

SELECT content_type , rating , COUNT(*)
FROM netflix_titles
GROUP BY content_type , rating 
ORDER BY COUNT(*) DESC;


SELECT content_type , rating , ranking FROM 
( SELECT content_type , rating , COUNT(*),
RANK() OVER (PARTITION BY content_type ORDER BY COUNT(*) DESC) AS ranking 
FROM netflix_titles
GROUP BY content_type , rating ) AS t
WHERE ranking = 1;


-- 3. List all Movies that is released in 2020

SELECT * FROM netflix_titles
WHERE content_type = 'Movie' AND release_year = '2020';


-- 4. Find the top 5 countries with the most content on Netflix 

SELECT country , COUNT(show_id)
FROM netflix_titles
GROUP BY country;

SELECT country,
       COUNT(show_id) AS total_content
FROM netflix_titles
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify longest movie 

SELECT * FROM netflix_titles
WHERE content_type = 'Movie' AND duration =
(SELECT MAX(duration) FROM netflix_titles);


-- 6. Find content added in last 5 years

SELECT CURDATE() - INTERVAL 5 YEAR;


ALTER TABLE netflix_titles
ADD COLUMN date_parsed DATE;


SET SQL_SAFE_UPDATES = 0;

UPDATE netflix_titles
SET date_parsed = STR_TO_DATE(date_added, '%M %d, %Y');

SET SQL_SAFE_UPDATES = 1;


SELECT *
FROM netflix_titles
WHERE date >= CURDATE() - INTERVAL 5 YEAR;


-- 7. Find all the Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT * FROM netflix_titles
WHERE director = 'Rajiv Chilaka';

--- If there is two directors together ----

SELECT * FROM netflix_titles
WHERE director LIKE '%Rajiv Chilaka%';

--- If there is case-sensitive in name ---

SELECT * FROM netflix_titles
WHERE director LIKE '%Rajiv Chilaka%';


-- 8. List all the TV Shows with more than 5 seasons

SELECT * FROM netflix_titles
WHERE content_type = 'TV Show' and duration > '5 seasons';


-- 9. Count the number of content in each genre

SELECT TRIM(j.genre) AS genre,
       COUNT(nt.show_id) AS total_content
FROM netflix_titles nt
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(nt.listed_in, ',', '","'), '"]'),
    '$[*]' COLUMNS (genre VARCHAR(100) PATH '$')
) AS j
GROUP BY genre
ORDER BY total_content DESC;



-- 10. Find each year and the average numbers of content release by India on Netflix , return top 5 with highest avg content release

SELECT 
    YEAR(date) AS year,
    COUNT(*) AS yearly_content,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_titles WHERE country = 'India'),
        2
    ) AS average_content
FROM netflix_titles
WHERE country = 'India'
GROUP BY YEAR(date)
ORDER BY yearly_content DESC
LIMIT 5;



-- 11. List all Movies that are documentaries

SELECT *
FROM netflix_titles
WHERE content_type = 'Movie'
  AND listed_in LIKE '%Documentaries%';



-- 12. Find all content without director

SELECT * FROM netflix_titles
WHERE director IS NULL;


-- 13 . Find how many movies actor ' Salman Khan' appeared in last 10 years

SELECT *
FROM netflix_titles
WHERE cast LIKE '%Salman Khan%'
  AND release_year > YEAR(CURDATE()) - 10;



-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India 

SELECT TRIM(j.actor) AS actor,
       COUNT(*) AS total_appearances
FROM netflix_titles nt
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(nt.cast, ',', '","'), '"]'),
    '$[*]' COLUMNS (actor VARCHAR(100) PATH '$')
) AS j
WHERE nt.country LIKE '%India%'
GROUP BY actor
ORDER BY total_appearances DESC
LIMIT 10;



-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field and Label content containing these keywords as 'bad' and all other content as 'good'. Count how many items fall into each category

WITH new_table
AS 
(
SELECT *, 
CASE 
WHEN 
description LIKE '%kill%' or description LIKE '%violence%' 
THEN 'Bad_Content' ELSE 'Good_Content'
END category
FROM netflix_titles
)
SELECT category, COUNT(*) AS total
FROM new_table
GROUP BY category;



