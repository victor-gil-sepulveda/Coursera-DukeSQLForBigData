DATABASE UA_DILLARDS;

--------------
-- Question 1
--------------
SELECT EXTRACT(MONTH FROM saledate) AS dm, EXTRACT (YEAR FROM saledate) AS dy, COUNT (DISTINCT EXTRACT (DAY FROM saledate))
FROM trnsact
GROUP BY dy, dm
ORDER BY dy ASC, dm ASC;

--------------
-- Question 2
--------------
SELECT T.sku, 
SUM(CASE WHEN T.dm=6 THEN T.amt END) AS june_sum,
SUM(CASE WHEN T.dm=7 THEN T.amt END) AS july_sum,
SUM(CASE WHEN T.dm=8 THEN T.amt END) AS august_sum,
ZEROIFNULL(june_sum) + 
ZEROIFNULL(july_sum) + 
ZEROIFNULL(august_sum) AS combined_sum
FROM (
		SELECT sku, amt, EXTRACT (MONTH FROM saledate) as dm
		FROM trnsact
		WHERE stype = 'P' ) AS T
GROUP BY T.sku
ORDER BY combined_sum DESC;

--------------
-- Question 3
--------------
SELECT store, EXTRACT(MONTH FROM saledate) AS dm, EXTRACT (YEAR FROM saledate) AS dy, COUNT(*) AS num_days
FROM trnsact
GROUP BY store, dm, dy
ORDER BY num_days ASC;

--------------
-- Question 4
--------------
SELECT store, dm, dy, num_days, avg_daily_rev, dym
FROM (
	SELECT store, EXTRACT(MONTH FROM saledate) AS dm, EXTRACT (YEAR FROM saledate) AS dy, COUNT(DISTINCT saledate) AS num_days, SUM(amt) / num_days AS avg_daily_rev, EXTRACT(YEAR FROM saledate)||EXTRACT(MONTH FROM saledate) AS dym
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY store, dm, dy
	HAVING num_days >= 20 AND dym <> '2005 8') AS T
ORDER BY num_days ASC;

--------------
-- Question 5
--------------
SELECT store,  
CASE
	WHEN (msa_high >= 50 AND msa_high <= 60) THEN 'low'
  	WHEN (msa_high > 60 AND msa_high <= 70) THEN 'medium'
  	WHEN (msa_high > 70) THEN 'high'
   	ELSE 'very low'
END 
FROM store_msa;

SELECT msa.ranking, SUM(stores.total_rev)/SUM(stores.num_days) AS avg_sales_per_day
FROM (
	SELECT store, COUNT(DISTINCT saledate) AS num_days, SUM(amt) AS total_rev
	FROM trnsact
	WHERE stype = 'P' AND EXTRACT(YEAR FROM saledate)||EXTRACT(MONTH FROM saledate) <> '2005 8'
	GROUP BY store
	HAVING num_days >= 20 ) AS stores
JOIN (
	SELECT store,  
	CASE
		WHEN (msa_high >= 50 AND msa_high <= 60) THEN 'low'
	  	WHEN (msa_high > 60 AND msa_high <= 70) THEN 'medium'
	  	WHEN (msa_high > 70) THEN 'high'
	   	ELSE 'very low'
	END AS ranking
	FROM store_msa) AS msa
ON stores.store = msa.store
GROUP BY msa.ranking;


--------------
-- Question 6
--------------
SELECT stores.store, T.msa_income, T2.msa_income, stores.state, stores.city, stores.num_days / stores.total_rev
FROM (
	SELECT store, COUNT(DISTINCT saledate) AS num_days, SUM(amt) AS total_rev
	FROM trnsact
	WHERE stype = 'P' AND EXTRACT(YEAR FROM saledate)||EXTRACT(MONTH FROM saledate) <> '2005 8'
	GROUP BY store
	HAVING num_days >= 20 ) AS stores
JOIN (
	SELECT store,
	CASE
		WHEN (msa_high >= 50 AND msa_high <= 60) THEN 'low'
	  	WHEN (msa_high > 60 AND msa_high <= 70) THEN 'medium'
	  	WHEN (msa_high > 70) THEN 'high'
	   	ELSE 'very low'
	END AS ranking
	FROM store_msa ) AS msa
ON stores.store = msa.store
LEFT JOIN ( 
	SELECT store, msa_income 
	FROM (
		SELECT TOP 1 store, msa_income 
		FROM store_msa 
		ORDER BY msa_income DESC) AS subT) AS T
ON T.store = stores.store
LEFT JOIN ( 
	SELECT store, msa_income 
	FROM (
		SELECT TOP 1 store, msa_income 
		FROM store_msa 
		ORDER BY msa_income ASC) AS subT2) AS T2
ON T2.store = stores.store
WHERE T.msa_income IS NOT NULL OR T2.msa_income IS NOT NULL;

--------------
-- Question 7
--------------
-- Number of transactions per sku
SELECT sku, COUNT(DISTINCT saledate) AS num_transact, STDDEV_SAMP(sprice) AS std
FROM trnsact
GROUP BY sku
HAVING num_transact > 100;

SELECT S.sku, S.brand, T.std
FROM (
	SELECT TOP 1 sku, COUNT(DISTINCT saledate) AS num_transact, STDDEV_SAMP(sprice) AS std
	FROM trnsact
	GROUP BY sku
	HAVING num_transact > 100
	ORDER BY std DESC) AS T
JOIN skuinfo AS S
ON S.sku = T.sku; 

--------------
-- Question 8
--------------
SELECT T2.sku, T2.sprice, T.std
FROM (
	SELECT TOP 1 sku, COUNT(DISTINCT saledate) AS num_transact, STDDEV_SAMP(sprice) AS std
	FROM trnsact
	GROUP BY sku
	HAVING num_transact > 100
	ORDER BY std DESC) AS T
JOIN trnsact AS T2
ON T2.sku = T.sku; 

-- It looks there's an error in entry :#3733090 5005.00 178.6

--------------
-- Question 9
--------------
SELECT T.dm, SUM(T.daily_revenue) / SUM(T.num_days) AS daily_average
FROM (
	SELECT store, EXTRACT(MONTH FROM saledate) AS dm, EXTRACT (YEAR FROM saledate) AS dy, COUNT(DISTINCT saledate) AS num_days, SUM(amt) AS daily_revenue, EXTRACT(YEAR FROM saledate)||EXTRACT(MONTH FROM saledate) AS dym
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY store, dm, dy
	HAVING num_days >= 20 AND dym <> '2005 8') AS T
GROUP BY T.dm
ORDER BY T.dm ASC;

---------------
-- Question 10
---------------
-- Which department, in which city and state of what store, had the greatest % increase in average daily sales revenue from November to December?  
 
-- Still needs to address the department through an inner join at
-- subquery level (T). Then the department must be used also to group by
SELECT T2.store, msa.city, msa.state
FROM (
	SELECT TOP 1 T.store,
		SUM(CASE WHEN T.dm=11 THEN T.num_days END) AS nov_day_sum,
		SUM(CASE WHEN T.dm=12 THEN T.num_days END) AS dic_day_sum,
		SUM(CASE WHEN T.dm=11 THEN T.daily_revenue END) AS nov_rev_sum,
		SUM(CASE WHEN T.dm=12 THEN T.daily_revenue END) AS dic_rev_sum,
		nov_rev_sum / nov_day_sum AS y,
	 	dic_rev_sum / dic_day_sum AS x,
		((x-y)/y)*100 AS percent_inc
	FROM (
		SELECT store, EXTRACT(MONTH FROM saledate) AS dm, EXTRACT (YEAR FROM saledate) AS dy, COUNT(DISTINCT saledate) AS num_days, SUM(amt) AS daily_revenue
		FROM trnsact
		WHERE stype = 'P'
		GROUP BY store, dm, dy
		HAVING num_days >= 20 AND dm IN (11,12)) AS T
	GROUP BY store
	ORDER BY percent_inc DESC) AS T2
JOIN store_msa AS msa
ON T2.store = msa.store;

---------------
-- Question 11
---------------
-- Exercise 11:  What is the city and state of the store that had the greatest decrease in average daily revenue from August to September? 
SELECT T2.store, msa.city, msa.state
FROM (
	SELECT TOP 1 T.store,
		SUM(CASE WHEN T.dm=8 THEN T.num_days END) AS aug_day_sum,
		SUM(CASE WHEN T.dm=9 THEN T.num_days END) AS sept_day_sum,
		SUM(CASE WHEN T.dm=8 THEN T.daily_revenue END) AS aug_rev_sum,
		SUM(CASE WHEN T.dm=9 THEN T.daily_revenue END) AS sept_rev_sum,
		aug_day_sum / aug_rev_sum AS y,
	 	sept_day_sum / sept_rev_sum AS x,
		x-y AS change
	FROM (
		SELECT store, EXTRACT(MONTH FROM saledate) AS dm, EXTRACT (YEAR FROM saledate) AS dy, COUNT(DISTINCT saledate) AS num_days, SUM(amt) AS daily_revenue, EXTRACT(YEAR FROM saledate)||EXTRACT(MONTH FROM saledate) AS dym
		FROM trnsact
		WHERE stype = 'P'
		GROUP BY store, dm, dy
		HAVING num_days >= 20 AND dm IN (8,9) AND dym <> '2005 8') AS T
	GROUP BY store
	ORDER BY change ASC) AS T2
JOIN store_msa AS msa
ON T2.store = msa.store;

---------------
-- Question 12
---------------
-- Exercise 12:  Determine the month of maximum total revenue for each store. Count the number of stores whose month of maximum total revenue was in each of the twelve months.  Then determine the month of maximum average daily revenue.  Count the number of stores whose month of maximum average daily revenue was in each of the twelve months. How do they compare?

SELECT T.dm, COUNT(DISTINCT T.store)
FROM (
	SELECT store, EXTRACT(MONTH FROM saledate) AS dm, EXTRACT (YEAR FROM saledate) AS dy, COUNT(DISTINCT saledate) AS num_days, SUM(amt) AS daily_revenue, daily_revenue / num_days AS avg_daily_rev, EXTRACT(YEAR FROM saledate)||EXTRACT(MONTH FROM saledate) AS dym, RANK() OVER(PARTITION BY store ORDER BY avg_daily_rev DESC) AS ranking
		FROM trnsact
		WHERE stype = 'P'
		GROUP BY store, dm, dy
		HAVING num_days >= 20 AND dym <> '2005 8') AS T
WHERE T.ranking = 1
GROUP BY T.dm;
 
