----------------
-- Question 2
----------------
-- Right join
----------------
-- Question 3
----------------
-- On what day was Dillard’s income based on total sum of purchases the greatest

SELECT TOP 1 saledate, SUM(trnsact.amt) AS total_purchases
FROM trnsact
GROUP BY trnsact.saledate
ORDER BY total_purchases DESC;
-- 04/12/18

----------------
-- Question 4
----------------
-- What is the deptdesc of the departments that have the top 3 greatest numbers of 
-- skus from the skuinfo table associated with them?

SELECT deptinfo.dept, deptinfo.deptdesc,  nr_different_skus
FROM 
	(SELECT TOP 3 deptinfo.dept, COUNT(UNIQUE skuinfo.sku) as nr_different_skus
	FROM skuinfo
	JOIN deptinfo
	ON skuinfo.dept = deptinfo.dept
	GROUP BY deptinfo.dept
	ORDER BY nr_different_skus DESC) AS T
JOIN deptinfo
ON T.dept = deptinfo.dept;
-- INVEST, POLOMEN, BRIOSO

----------------
-- Question 5
----------------
-- Which table contains the most distinct sku numbers?
SELECT 'skstinfo' AS table_name , COUNT(UNIQUE sku) AS num_sku
FROM skstinfo
UNION
SELECT 'skuinfo' AS table_name , COUNT(UNIQUE sku) AS num_sku
FROM skuinfo
UNION  
SELECT 'transact' AS table_name , COUNT(UNIQUE sku) AS num_sku
FROM trnsact;
-- skuinfo

----------------
-- Question 6
----------------
SELECT COUNT(*)
FROM skstinfo
LEFT OUTER JOIN skuinfo
ON  skstinfo.sku = skuinfo.sku
WHERE skuinfo.sku IS NULL;
-- 0

----------------
-- Question 7
----------------
SELECT AVG(T.profit) (DECIMAL (10,5))
FROM
	(SELECT saledate, SUM((trnsact.sprice - skstinfo.cost)*trnsact.quantity) as profit
	FROM skstinfo
	JOIN trnsact
	ON skstinfo.sku = trnsact.sku AND skstinfo.store = trnsact.store
	WHERE trnsact.stype = 'P' AND trnsact.sprice <> 0
	GROUP BY saledate) AS T;
-- 1.53M

----------------
-- Question 8
----------------
SELECT COUNT(DISTINCT store), MIN(msa_pop), MAX(msa_income)
FROM store_msa
GROUP BY store
HAVING state = 'NC';
-- 16 339511 36151
-- 16 MSAs, lowest population of 339,511, highest income level of $36,151

----------------
-- Question 9
----------------
-- It can be chained with a JOIN deptinfo in order to pick the
-- description

SELECT deptinfo.dept, SUM(trnsact.amt) as total_sales, skuinfo.color, skuinfo.style, skuinfo.brand
FROM deptinfo
JOIN skuinfo
ON deptinfo.dept = skuinfo.dept
JOIN trnsact
ON skuinfo.sku = trnsact.sku
GROUP BY deptinfo.dept, skuinfo.color, skuinfo.style, skuinfo.brand
ORDER BY total_sales DESC;
-- 800 6438658.07 DDML 6142 CLINIQUE 

----------------
-- Question 10
----------------
SELECT COUNT(*)
FROM 
	(SELECT strinfo.store
	FROM skstinfo
	JOIN strinfo
	ON strinfo.store = skstinfo.store
	GROUP BY strinfo.store
	HAVING COUNT(DISTINCT skstinfo.sku) > 180000) AS T;
-- 12

----------------
-- Question 11
----------------
SELECT *
FROM skuinfo
JOIN deptinfo
ON skuinfo.dept = deptinfo.dept
WHERE deptinfo.deptdesc = 'cop' AND skuinfo.brand = 'federal' AND skuinfo.color = 'rinse wash'  
-- size and style are different

----------------
-- Question 12
----------------
SELECT COUNT(*)
FROM skuinfo
LEFT JOIN skstinfo
ON skuinfo.sku = skstinfo.sku
WHERE skstinfo.sku IS NULL;
-- 803966

----------------
-- Question 13
----------------
-- A performance improvement could be to get only one row in the
-- subquery

SELECT strinfo.city, strinfo.state, T.total_sales
FROM 
	(SELECT trnsact.store AS store, SUM(trnsact.amt) AS total_sales
	FROM trnsact
	GROUP BY trnsact.store) AS T
JOIN strinfo
ON strinfo.store  = T.store
ORDER BY T.total_sales DESC;
-- METAIRIE LA 27058653.42

----------------
-- Question 14
----------------
-- left join

----------------
-- Question 15
----------------
--  How many states have more than 10 Dillards stores in them? 
SELECT COUNT(*)
FROM 
	(SELECT state, COUNT(DISTINCT store) AS num_stores
	FROM strinfo
	GROUP BY state
	HAVING COUNT(DISTINCT store) > 10) AS T;
-- 15

----------------
-- Question 16
----------------
SELECT skuinfo.sku, skstinfo.retail
FROM skuinfo
JOIN skstinfo
ON skuinfo.sku = skstinfo.sku
JOIN deptinfo
ON skuinfo.dept = deptinfo.dept
WHERE deptinfo.deptdesc = 'reebok' AND skuinfo.brand = 'skechers' AND skuinfo.color = 'wht/saphire'
-- 29
