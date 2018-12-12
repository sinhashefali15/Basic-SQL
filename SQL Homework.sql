USE sakila;

#1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor
ORDER BY first_name, last_name;


#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UCASE(CONCAT(first_name, ' ', last_name)) AS Actor_Name
FROM actor
ORDER BY first_name, last_name;


#2a. find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'joe'
ORDER BY first_name, last_name;


#2b. Find all actors whose last name contain the letters GEN:
SELECT *
FROM actor
WHERE last_name LIKE '%gen%'
ORDER BY last_name, first_name;


#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name LIKE '%li%'
ORDER BY last_name, first_name;


#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ( 'Afghanistan', 'Bangladesh', 'China');


#3a. create a column in the table actor named description and use the data type BLOB.
ALTER TABLE actor
ADD COLUMN description BLOB;


#3b. Delete the description column.
ALTER TABLE actor
DROP description;


#4a. List the last names of actors, as well as how many actors have that last name.
SELECT DISTINCT last_name, COUNT(last_name) AS 'No. of Actors'
FROM actor
GROUP BY last_name
ORDER BY 'No. of Actors';


#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
SELECT DISTINCT last_name, COUNT(last_name) AS 'No. of Actors'
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1
ORDER BY 'No. of Actors';


#4c. Update GROUCHO WILLIAMS to HARPO WILLIAMS. 
UPDATE actor
SET first_name = 'HARPO' 
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';


#4d. In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
/*SELECT *
FROM actor
WHERE first_name = 'GROUCHO'
AND last_name = 'WILLIAMS'
ORDER BY last_name, first_name;

-- 172	GROUCHO	WILLIAMS
*/

UPDATE actor
SET first_name = CASE WHEN first_name = 'HARPO' THEN 'GROUCHO' END 
WHERE actor_id = 172;


#5a. Re-create the schema of the address table.
DESC address; 


 CREATE TABLE `address` (
  `address_id` SMALLINT(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` VARCHAR(50) NOT NULL,
  `address2` VARCHAR(50) DEFAULT NULL,
  `district` VARCHAR(20) NOT NULL,
  `city_id` SMALLINT(5) unsigned NOT NULL,
  `postal_code` VARCHAR(10) DEFAULT NULL,
  `phone` VARCHAR(20) NOT NULL,
  `location` GEOMETRY NOT NULL,
  `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8 


#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, s.email, s.username, a.address, a.address2, district, c.city
FROM staff S
JOIN address a ON a.address_id = s.address_id
JOIN city c ON c.city_id = a.city_id;


#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT p.staff_id, s.first_name, s.last_name, SUM(amount) 'Total Amount'
FROM payment p
JOIN staff s ON s.staff_id = p.staff_id
WHERE p.payment_date LIKE '%2005-08%'
GROUP BY p.staff_id, s.first_name, s.last_name;


#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(DISTINCT fa.actor_id) 'No. Of Actors'
FROM film F
JOIN film_actor fa ON fa.film_id = f.film_id
GROUP BY f.title
ORDER BY f.title;


#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT F.TITLE, COUNT(i.inventory_id) 'No. Of Copies'
FROM film F
JOIN inventory i ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible'
GROUP BY F.TITLE;


#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT C.last_name, C.first_name, SUM(P.amount) 'Total Amount Paid'
FROM payment P
JOIN customer C ON C.customer_id = P.customer_id
GROUP BY C.last_name, C.first_name
ORDER BY C.last_name;


#7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT DISTINCT title
FROM film 
WHERE language_id IN ( SELECT language_id
					   FROM language
                       WHERE language_id = 1 ) -- English
AND (title LIKE 'K%' OR title LIKE 'Q%')                      
ORDER BY title;


#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name 
FROM actor
WHERE actor_id IN ( SELECT actor_id 
                    FROM film_actor
					WHERE film_id IN  ( SELECT film_id 
                                        FROM film
										WHERE title = "Alone Trip"))
ORDER BY first_name, last_name;


#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT cs.first_name, cs.last_name, cs.email, co.country 
FROM customer cs
LEFT JOIN address a ON cs.address_id = a.address_id
LEFT JOIN city ci ON ci.city_id = a.city_id
LEFT JOIN country co ON co.country_id = ci.country_id
WHERE country = "Canada"
ORDER BY cs.first_name, cs.last_name;


#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.*, c.name AS 'Film Category' 
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
WHERE c.category_id = 8 -- Family
ORDER BY title;


#7e. Display the most frequently rented movies in descending order.
SELECT f.title , COUNT(r.rental_id) AS "Total Rentals" 
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY f.title
ORDER BY COUNT(r.rental_id) DESC;


#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, a.address, a.district, c.city, SUM(amount) AS 'Total Revenue'
FROM store s
JOIN staff st ON s.store_id = st.store_id
JOIN payment p ON st.staff_id = p.staff_id
JOIN address a ON a.address_id = s.address_id
JOIN city c ON c.city_id = a.city_id 
GROUP BY s.store_id, a.address, a.district, c.city;


#7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, a.address, a.district, c.city, cn.country
FROM store s
JOIN address a ON a.address_id = s.address_id
JOIN city c ON c.city_id = a.city_id
JOIN country cn on cn.country_id = c.country_id;


#7h. List the top five genres in gross revenue in descending order. 

SELECT c.name, SUM(p.amount)  AS 'Gross Revenue'
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY name
ORDER BY SUM(p.amount) DESC
LIMIT 5;


#8a. Creatye view to display top 5 genre
CREATE VIEW Top5Genre AS
SELECT c.name, SUM(p.amount) AS 'Gross Revenue' 
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY name 
ORDER BY SUM(p.amount) DESC
LIMIT 5;


#8b. display the view that you created in 8a.
SELECT *
FROM Top5Genre;


#8c. Delete the above view created.
DROP VIEW Top5Genre;
