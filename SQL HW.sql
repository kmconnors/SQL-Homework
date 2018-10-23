USE sakila;

-- DONE 1a. Display the first and last names of all actors from the table `actor`. 
SELECT first_name, last_name FROM actor;

-- DONE 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT UPPER(CONCAT(FIRST_NAME, " ", LAST_NAME)) AS "ACTOR NAME" FROM ACTOR;

-- DONE 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT ACTOR_ID, FIRST_NAME, LAST_NAME FROM actor WHERE first_name = "JOE";

-- DONE 2b. Find all actors whose last name contain the letters `GEN`
SELECT * FROM actor WHERE last_name like '%GEN%';

-- DONE 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order
SELECT * FROM actor WHERE last_name like '%LI%' ORDER BY last_name, first_name;

-- DONE 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id, country FROM country WHERE country in ("Afghanistan", "Bangladesh", "China");

-- DONE 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the 
-- type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE `sakila`.`actor` 
ADD COLUMN `DESCRIPTION` BLOB NULL AFTER `last_update`;
-- Verify the change
SELECT * FROM actor;

-- DONE 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor 
DROP COLUMN `DESCRIPTION`;
-- Verify the change
SELECT * FROM actor;

-- DONE 4a. List the last names of actors, as well as how many actors have that last name.
SELECT LAST_NAME, COUNT(LAST_NAME) as "ACTOR COUNT"
FROM ACTOR
GROUP BY LAST_NAME ORDER BY LAST_NAME ASC;

-- DONE 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT LAST_NAME, COUNT(*) FROM ACTOR GROUP BY LAST_NAME ASC HAVING COUNT(*)>=2;

-- DONE 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
-- Review how many records include the actor's first name as GROUCHO
SELECT * FROM actor WHERE first_name = "GROUCHO";
-- Ensure only 1 record is assigned actor_id 172
SELECT * FROM actor WHERE actor_id = 172;
-- Update the Record
UPDATE actor SET first_name = "HARPO" WHERE actor_id = 172;
-- Verify that the record now appears correct
SELECT * FROM actor WHERE actor_id = 172;

-- DONE 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, 
-- if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
-- Check how many records include an actor with the first name HARPO
SELECT * FROM actor WHERE first_name = "HARPO";
-- Update the record
UPDATE actor SET first_name = "GROUCHO" where actor_id = 172;
-- Verify that the record now appears correct
SELECT * FROM actor WHERE actor_id = 172;

-- DONE 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
DESCRIBE address;

-- DONE 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`
-- select address, city from address a join city c on (a.city_id=c.city_id);
SELECT a.address, c.city from address a JOIN city c ON (a.city_id = c.city_id);

-- DONE 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT SUM(P.AMOUNT), S.STAFF_ID, S.FIRST_NAME, S.LAST_NAME FROM PAYMENT P JOIN STAFF S ON (P.STAFF_ID=S.STAFF_ID) AND P.PAYMENT_DATE >= '2005-08-01 00:00:00' AND PAYMENT_DATE <= '2005-08-31 24:60:60' GROUP BY S.STAFF_ID;

-- DONE 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join
SELECT COUNT(A.ACTOR_ID), F.FILM_ID, F.TITLE FROM FILM_ACTOR A JOIN FILM F ON (A.FILM_ID=F.FILM_ID) GROUP BY F.FILM_ID;

-- DONE 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(inventory_id) from inventory WHERE film_id = ( SELECT FILM_ID FROM FILM WHERE TITLE = "HUNCHBACK IMPOSSIBLE" );

-- DONE 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name: ![Total amount paid](Images/total_payment.png)
SELECT SUM(P.AMOUNT), P.CUSTOMER_ID, C.LAST_NAME, C.FIRST_NAME FROM PAYMENT P JOIN CUSTOMER C ON (P.CUSTOMER_ID=C.CUSTOMER_ID) GROUP BY P.CUSTOMER_ID ORDER BY LAST_NAME ASC;

-- DONE 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles 
-- of movies starting with the letters `K` and `Q` whose language is English.
SELECT TITLE FROM FILM WHERE TITLE LIKE "Q%" OR TITLE LIKE "K%" AND LANGUAGE_ID = ( SELECT LANGUAGE_ID FROM LANGUAGE WHERE NAME = "ENGLISH" );

-- DONE 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT FIRST_NAME, LAST_NAME FROM ACTOR WHERE ACTOR_ID IN ( SELECT ACTOR_ID FROM FILM_ACTOR WHERE FILM_ID = ( SELECT FILM_ID FROM FILM WHERE TITLE = "ALONE TRIP" ) );

-- DONE 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
-- of all Canadian customers. Use joins to retrieve this information
SELECT * FROM CUSTOMER WHERE ADDRESS_ID IN ( SELECT ADDRESS_ID FROM ADDRESS WHERE CITY_ID IN 
( SELECT CITY_ID FROM CITY WHERE COUNTRY_ID = (SELECT COUNTRY_ID FROM COUNTRY WHERE COUNTRY = "CANADA" ) ) ) ;

-- DONE 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify 
-- all movies categorized as family films.
SELECT * FROM FILM WHERE RATING = "G";

-- DONE 7e. Display the most frequently rented movies in descending order.
SELECT F.FILM_ID, F.TITLE, I.INVENTORY_ID, COUNT(R.RENTAL_ID) FROM FILM F LEFT JOIN INVENTORY I ON (F.FILM_ID=I.FILM_ID)
LEFT JOIN RENTAL R ON (I.INVENTORY_ID=R.INVENTORY_ID) GROUP BY F.FILM_ID ORDER BY COUNT(R.RENTAL_ID) DESC;

-- DONE 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT S.STORE_ID, P.STAFF_ID, SUM(P.AMOUNT) FROM STAFF S LEFT JOIN PAYMENT P ON (S.STAFF_ID=P.STAFF_ID) GROUP BY P.STAFF_ID;

-- DONE 7g. Write a query to display for each store its store ID, city, and country.
SELECT S.STORE_ID, C.CITY, O.COUNTRY FROM STORE S 
LEFT JOIN ADDRESS A ON (S.ADDRESS_ID=A.ADDRESS_ID)
LEFT JOIN CITY C ON (A.CITY_ID=C.CITY_ID)
LEFT JOIN COUNTRY O ON (C.COUNTRY_ID=O.COUNTRY_ID);

-- DONE 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: 
-- category, film_category, inventory, payment, and rental.)
SELECT SUM(P.AMOUNT), C.NAME FROM CATEGORY C LEFT JOIN FILM_CATEGORY F ON (C.CATEGORY_ID=F.CATEGORY_ID)
LEFT JOIN INVENTORY I ON (F.FILM_ID=I.FILM_ID) LEFT JOIN RENTAL R ON (I.INVENTORY_ID=R.INVENTORY_ID)
LEFT JOIN PAYMENT P ON (R.RENTAL_ID=P.RENTAL_ID) GROUP BY C.NAME ORDER BY SUM(P.AMOUNT) DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE TABLE TOP_FIVE_GENRES
(id INT auto_increment NOT NULL, Movie_Genre VARCHAR(30),
Gross_Sales float,
PRIMARY KEY (id)
);

SELECT C.NAME AS "MOVIE GENRE", SUM(P.AMOUNT) AS "GROSS SALES" FROM CATEGORY C LEFT JOIN FILM_CATEGORY F ON (C.CATEGORY_ID=F.CATEGORY_ID)
LEFT JOIN INVENTORY I ON (F.FILM_ID=I.FILM_ID) LEFT JOIN RENTAL R ON (I.INVENTORY_ID=R.INVENTORY_ID)
LEFT JOIN PAYMENT P ON (R.RENTAL_ID=P.RENTAL_ID) GROUP BY C.NAME ORDER BY SUM(P.AMOUNT) DESC LIMIT 5;
-- 8b. How would you display the view that you created in 8a?
-- Assuming this is a key metric that I want to track on a daily basis, I would create a dashboard that would pop up each day when I arrived at the office so I would know what was selling well
-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP TABLE TOP_FIVE_GENRES;

-- If I used a 