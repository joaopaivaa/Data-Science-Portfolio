SELECT * FROM actors;
SELECT * FROM directors;
SELECT * FROM movies;
SELECT * FROM movies_actors;
SELECT * FROM movies_revenues;

-- Male actors
SELECT CONCAT(IFNULL(CONCAT(' ', first_name), ''), IFNULL(CONCAT(' ', last_name), '')), gender
FROM actors
WHERE gender = 'M'
ORDER BY 1 ASC;

-- Number of actors by gender
SELECT gender, COUNT(gender='M') AS Quantity
FROM actors
GROUP BY gender
ORDER BY 2 DESC;

-- Non english movies
SELECT movie_name, movie_lang
FROM movies
WHERE movie_lang <> 'English'
ORDER BY 2 ASC, 1 ASC;

-- Only chinese and japanese movies
SELECT movie_name, movie_lang
FROM movies
WHERE movie_lang IN ('Chinese', 'Japanese')
ORDER BY 2 ASC, 1 ASC;

-- Number of movies by language
SELECT movie_lang, COUNT(movie_lang) AS Quantity
FROM movies
GROUP BY movie_lang
ORDER BY 2 DESC, 1 ASC;

-- Movies total revenue (national + international)
SELECT movies.movie_name, SUM(COALESCE(movies_revenues.revenues_domestic,0) + COALESCE(movies_revenues.revenues_international,0)) AS total_revenue
FROM movies_revenues
INNER JOIN movies ON movies.movie_id = movies_revenues.movie_id
GROUP BY movies.movie_name
ORDER BY 2 DESC, 1 ASC;

-- Longest movies and it's director
SELECT movies.movie_name, movies.movie_length, CONCAT(directors.first_name, ' ', directors.last_name) AS directors_name
FROM movies
INNER JOIN directors ON movies.director_id = directors.director_id
ORDER BY 2 DESC, 1 ASC, 3 ASC;

-- Average movie length and number of movies by director
SELECT CONCAT(directors.first_name, ' ', directors.last_name) AS directors_name, ROUND(AVG(movies.movie_length),2) AS average_movie_length, COUNT(movies.movie_id)
FROM movies
INNER JOIN directors ON movies.director_id = directors.director_id
GROUP BY directors_name
ORDER BY 2 DESC, 3 ASC, 1 ASC;

-- Total revenue by director
SELECT	CONCAT(directors.first_name, ' ', directors.last_name) AS directors_name,
		SUM(COALESCE(movies_revenues.revenues_domestic,0) + COALESCE(movies_revenues.revenues_international,0)) AS total_revenue
FROM movies
INNER JOIN movies_revenues ON movies.movie_id = movies_revenues.movie_id
INNER JOIN directors ON directors.director_id = movies.director_id
GROUP BY directors_name
ORDER BY 2 DESC, 1 ASC;
