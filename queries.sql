CREATE TABLE continents
(
    continent_id   SERIAL PRIMARY KEY,
    continent_name VARCHAR(255) NOT NULL
);

CREATE TABLE countries
(
    country_id   SERIAL PRIMARY KEY,
    country_name VARCHAR(255) NOT NULL,
    continent_id INTEGER REFERENCES continents (continent_id) ON DELETE CASCADE
);

CREATE TABLE people
(
    person_id   SERIAL PRIMARY KEY,
    person_name VARCHAR(255) NOT NULL
);

CREATE TABLE country_people
(
    country_id INTEGER REFERENCES countries (country_id) ON DELETE CASCADE,
    person_id  INTEGER REFERENCES people (person_id) ON DELETE CASCADE,
    PRIMARY KEY (country_id, person_id)
);

ALTER TABLE people
    ADD COLUMN person_surname VARCHAR(255);

INSERT INTO continents (continent_name)
VALUES ('Asia'),
       ('Europe'),
       ('North America'),
       ('South America'),
       ('Africa'),
       ('Oceania');

INSERT INTO countries (country_name, continent_id)
VALUES ('China', 1),
       ('Germany', 2),
       ('United States', 3),
       ('Brazil', 4),
       ('Nigeria', 5),
       ('Australia', 6);

INSERT INTO people (person_name, person_surname)
VALUES ('Alice', 'Brown'),
       ('Alice', 'Smith'),
       ('Bob', 'Johnson'),
       ('Charlie', 'Brown'),
       ('David', 'Williams'),
       ('Eva', 'Jones'),
       ('Frank', 'Taylor');

INSERT INTO country_people (country_id, person_id)
VALUES (1, 1),
       (1, 2),
       (1, 3),
       (2, 2),
       (2, 4),
       (3, 1),
       (3, 3),
       (3, 5),
       (4, 2),
       (4, 4),
       (5, 3),
       (5, 5),
       (6, 4),
       (6, 6);

SELECT c.country_id, c.country_name
FROM countries c
ORDER BY (SELECT COUNT(person_id) FROM country_people cp WHERE cp.country_id = c.country_id) DESC LIMIT 1;


SELECT c.country_id, c.country_name
FROM countries c
ORDER BY (SELECT COUNT(person_id) FROM country_people cp WHERE cp.country_id = c.country_id) ASC LIMIT 2;

INSERT INTO countries (country_name, continent_id)
VALUES ('India', 1),
       ('France', 2);

SELECT DISTINCT c.country_id, c.country_name
FROM countries c
         JOIN country_people on c.country_id = country_people.country_id
WHERE country_people.country_id IN (SELECT country_id
                                    FROM country_people
                                    GROUP BY country_id
                                    HAVING COUNT(person_id) >= (SELECT AVG(all_people)
                                                                FROM (SELECT COUNT(person_id) AS all_people
                                                                      FROM country_people
                                                                      GROUP BY country_id) as cpap));

SELECT country_name
FROM countries
WHERE LENGTH(country_name) =
      (SELECT MAX(LENGTH(country_name))
       FROM countries);

SELECT country_name
FROM countries
WHERE country_name like '%F%'
ORDER BY country_name ASC;

SELECT cp.country_id, COUNT(cp.person_id) AS total_people
FROM country_people cp
GROUP BY cp.country_id
ORDER BY ABS(COUNT(cp.person_id) - (SELECT AVG(person_count)
                                    FROM (SELECT COUNT(person_id) AS person_count
                                          FROM country_people
                                          GROUP BY country_id) AS subquery)) ASC LIMIT 1;

SELECT continents.continent_name, COUNT(DISTINCT countries.country_id) AS country_count
FROM countries
         JOIN continents ON countries.continent_id = continents.continent_id
GROUP BY continents.continent_id, continents.continent_name;

SELECT people.person_id, people.person_name, COUNT(country_people.country_id) AS citizenship_count
FROM people
         JOIN country_people ON people.person_id = country_people.person_id
GROUP BY people.person_id, people.person_name
ORDER BY citizenship_count DESC LIMIT 1;

SELECT c.continent_id, c.continent_name, COUNT(p.person_id) AS people_count
FROM continents c
         JOIN countries co ON c.continent_id = co.continent_id
         JOIN country_people cp ON co.country_id = cp.country_id
         JOIN people p ON cp.person_id = p.person_id
GROUP BY c.continent_id, c.continent_name
ORDER BY people_count DESC LIMIT 1;

SELECT p1.person_id AS person_id_1, p2.person_id AS person_id_2, p1.person_name
FROM people p1
         JOIN people p2 ON p1.person_name = p2.person_name AND p1.person_id < p2.person_id;

CREATE TABLE authors
(
    author_id   SERIAL PRIMARY KEY,
    author_name VARCHAR(255) NOT NULL
);

CREATE TABLE books
(
    book_id          SERIAL PRIMARY KEY,
    title            VARCHAR(255) NOT NULL,
    author_id        INTEGER REFERENCES authors (author_id),
    publication_year INTEGER,
    copies_available INTEGER
);

INSERT INTO authors (author_name)
VALUES ('Arkady Strugatsky and Boris Strugatsky'),
       ('Richard Bach');

INSERT INTO books (title, author_id, publication_year, copies_available)
VALUES ('Monday Begins on Saturday', 1, 1965, 5),
       ('Roadside Picnic', 1, 1972, 3),
       ('Running from Safety: An Adventure of the Spirit', 2, 1994, 8);

INSERT INTO books (title, author_id, publication_year, copies_available)
VALUES ('Jonathan Livingston Seagull', 2, 1970, 10);

SELECT *
FROM books;

UPDATE books
SET copies_available = 12
WHERE book_id = 1;

DELETE
FROM books
WHERE book_id = 3;

SELECT *
FROM books
WHERE author_id = 1
  AND publication_year > 1971
ORDER BY publication_year DESC;

SELECT books.title, authors.author_name
FROM books
         JOIN authors ON books.author_id = authors.author_id;