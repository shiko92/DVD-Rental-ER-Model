
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