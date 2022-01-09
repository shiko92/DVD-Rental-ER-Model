Skip to content
Search or jump to…
Pull requests
Issues
Marketplace
Explore
 
@shiko92 
shiko92
/
DVD-Rental-ER-Model
Public
Code
Issues
Pull requests
Actions
Projects
Wiki
Security
Insights
Settings
DVD-Rental-ER-Model/Queries.txt
@shiko92
shiko92 Add files via upload
Latest commit 5e7883a on Dec 20, 2020
 History
 1 contributor
143 lines (107 sloc)  3.13 KB
   
/*Question # 1*/
/*query used to get desired fil categories */
WITH family_categories
AS (SELECT
  f.film_id film_id,
  f.title film_titles,
  c.name category
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON c.category_id = fc.category_id
WHERE c.category_id IN (2,3,4,5,8,12)),


/*query used to get total counts of rents per movie */
total_film_rents
AS (SELECT
  t2.film_id,
  t2.total_rent,
  t2.film_title
FROM (SELECT
  t1.film_id film_id,
  SUM(t1.rent_per_copy) OVER (PARTITION BY t1.film_id) AS total_rent,
  t1.title film_title
FROM (SELECT
  i.inventory_id,
  COUNT(r.rental_id) rent_per_copy,
  i.film_id,
  f.title
FROM inventory i
FULL JOIN rental r
  ON i.inventory_id = r.inventory_id
JOIN film f ON f.film_id = i.film_id
GROUP BY 1,3,4) t1) t2
GROUP BY 1,2,3)

/*main quary use to get total rents for desired categories */
SELECT
  film_titles film_title,
  category,
  total_rent
FROM family_categories
JOIN total_film_rents ON family_categories.film_id = total_film_rents.film_id
ORDER BY 2, 1, 3 DESC








/*Question # 2*/
WITH family_categories
AS (SELECT
  f.film_id film_id,
  f.title film_titles,
  c.name category,
  f.rental_duration AS rental_duration,
  NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile

FROM film f
JOIN film_category fc
  ON f.film_id = fc.film_id
JOIN category c ON c.category_id = fc.category_id
WHERE c.category_id IN (2,3,4,5,8,12)),

standard_quartile
AS (SELECT
  f.film_id film_id,
  f.title film_title,
  f.rental_duration
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON c.category_id = fc.category_id)

SELECT
  category,
  standard_quartile,
  COUNT(standard_quartile)
FROM family_categories
JOIN standard_quartile ON family_categories.film_id = standard_quartile.film_id

GROUP BY 1, 2
ORDER BY 1, 2








/*Queston # 3*/
SELECT
  DATE_PART('month', rental_date) AS month,
  CASE
    WHEN rental_date < '2006-01-01' THEN '2005'
    ELSE '2006'
  END AS year,
  staff_id store_id,
  COUNT(*) COUNT_rentals

FROM rental
GROUP BY 1, 2, 3
ORDER BY 4 DESC, 1






/*Queston # 4*/
WITH top10 AS 
( 
         SELECT   Date_TRUNC('year', p.payment_date), 
                  p.customer_id customer_id, 
                  SUM(p.amount), 
                  COUNT(p.amount), 
                           CONCAT(c.first_name, ' ', c.last_name) AS customer_name 
         FROM     payment p 
         JOIN     customer c ON p.customer_id = c.customer_id 
         GROUP BY 1, 2, 5 
         ORDER BY 3 DESC limit 10), monthly_payment AS 
( 
         SELECT   Date_trunc('month', payment_date) AS month, 
                  customer_id, 
                  SUM(amount)   amount, 
                  COUNT(amount) count 
         FROM     payment 
         GROUP BY 1, 2 ) 
SELECT   monthly_payment.month, 
         top10.customer_name, 
         monthly_payment.count  rents_counts, 
         monthly_payment.amount amount 
FROM     top10 
JOIN     monthly_payment ON top10.customer_id = monthly_payment.customer_id 
ORDER BY 2, 1






© 2022 GitHub, Inc.
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
