---------------
-- Question 2
---------------
-- How many distinct skus have the brand “Polo fas”, and are either size “XXL” or “black” in color?

SELECT COUNT(DISTINCT sku)
FROM skuinfo
WHERE brand = 'POLO FAS' AND (size = 'XXL' OR color = 'BLACK')
GROUP BY brand
-- 13623

---------------
-- Question 3
---------------
-- There was one store in the database which had only 11 days in one of its months (in other words, that store/month/year combination only contained 11 days of transaction data). In what city and state was this store located?

SELECT T.store, T.num_days, msa.state, msa.city
FROM (
	SELECT store, EXTRACT(MONTH FROM saledate) AS dm, EXTRACT (YEAR FROM saledate) AS dy, COUNT(DISTINCT saledate) AS num_days
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY store, dm, dy) AS T
JOIN store_msa as msa
ON msa.store = T.store
WHERE num_days = 11;
-- 6402 11 GA ATLANTA

---------------
-- Question 4
---------------
-- Which sku number had the greatest increase in total sales revenue from November to December?

SELECT TOP 1 T.sku,
	SUM(CASE WHEN T.dm=11 THEN T.daily_revenue END) AS nov_rev_sum,
	SUM(CASE WHEN T.dm=12 THEN T.daily_revenue END) AS dic_rev_sum,
	dic_rev_sum - nov_rev_sum AS rev_inc
FROM (
	SELECT sku, EXTRACT(MONTH FROM saledate) AS dm, EXTRACT (YEAR FROM saledate) AS dy, COUNT(DISTINCT saledate) AS num_days, SUM(amt) AS daily_revenue
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY sku, dm, dy
	HAVING num_days >= 20 AND dm IN (11,12)) AS T
GROUP BY T.sku
ORDER BY rev_inc DESC;
-- 3949538 121176.70 936256.91 815080.21

---------------
-- Question 5
---------------
-- What vendor has the greatest number of distinct skus in the transaction table that do not exist in the skstinfo table? (Remember that vendors are listed as distinct numbers in our data set).

SELECT s.vendor, COUNT(DISTINCT s.sku) as num_skus
FROM trnsact AS t
RIGHT JOIN skuinfo AS s
ON t.sku = s.sku
WHERE t.sku IS NULL
GROUP BY s.vendor
ORDER BY num_skus;
-- 5715232 110606

---------------
-- Question 6
---------------
-- What is the brand of the sku with the greatest standard deviation in sprice? Only examine skus which have been part of over 100 transactions.

-- Only works with the oreplace variant,
-- the simple concat approach does not work.
-- Still trying to know why...
SELECT TOP 3 T.sku, s.brand, T.std
FROM (
	SELECT sku, COUNT(*) AS num_transacts, STDDEV_POP(sprice) AS std
	FROM trnsact
	WHERE stype = 'P'  
	GROUP BY sku
	HAVING num_transacts > 100) AS T
JOIN skuinfo AS s
ON T.sku = s.sku
ORDER BY std DESC;
-- 2762683 HART SCH 175

---------------
-- Question 7
---------------
-- What is the city and state of the store which had the greatest increase in average daily revenue (as defined in Teradata Week 5 Exercise Guide) from November to December?

SELECT T2.store, msa.city, msa.state
FROM (
	SELECT TOP 1 T.store,
		SUM(CASE WHEN T.dm=11 THEN T.num_days END) AS nov_day_sum,
		SUM(CASE WHEN T.dm=12 THEN T.num_days END) AS dic_day_sum,
		SUM(CASE WHEN T.dm=11 THEN T.daily_revenue END) AS nov_rev_sum,
		SUM(CASE WHEN T.dm=12 THEN T.daily_revenue END) AS dic_rev_sum,
		nov_rev_sum / nov_day_sum AS y,
	 	dic_rev_sum / dic_day_sum AS x,
		x-y AS increase
	FROM (
		SELECT store, EXTRACT(MONTH FROM saledate) AS dm, EXTRACT (YEAR FROM saledate) AS dy, COUNT(DISTINCT saledate) AS num_days, SUM(amt) AS daily_revenue
		FROM trnsact
		WHERE stype = 'P'
		GROUP BY store, dm, dy
		HAVING num_days >= 20 AND dm IN (11,12)) AS T
	GROUP BY store
	ORDER BY increase DESC) AS T2
JOIN store_msa AS msa
ON T2.store = msa.store;
-- 8402 METAIRIE LA

---------------
-- Question 8
---------------
-- Compare the average daily revenue (as defined in Teradata Week 5 Exercise Guide) of the store with the highest msa_income and the store with the lowest median msa_income (according to the msa_income field). In what city and state were these two stores, and which store had a higher average daily revenue? 

SELECT DISTINCT T.store, MAX(max_msa.msa_income) AS max_income, MIN(min_msa.msa_income) AS min_income, MAX(msa.city), MAX(msa.state), MAX(msa.msa_income), SUM(daily_revenue) / SUM(num_days) AS avg_daily_revenue
FROM (	
	SELECT store, EXTRACT(MONTH FROM saledate) AS dm, EXTRACT (YEAR FROM saledate) AS dy, COUNT(DISTINCT saledate) AS num_days, SUM(amt) AS daily_revenue, EXTRACT(YEAR FROM saledate)||EXTRACT(MONTH FROM saledate) AS dym
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY store, dm, dy
	HAVING num_days >= 20 AND dym <> '2005 8') AS T
JOIN store_msa AS msa
ON msa.store = T.store
LEFT JOIN  (
	SELECT TOP 1 store, msa_income
	FROM store_msa
	ORDER BY msa_income DESC) AS max_msa
ON max_msa.store = T.store 
LEFT JOIN  (
	SELECT TOP 1 store, msa_income
	FROM store_msa
	ORDER BY msa_income ASC) AS min_msa
ON min_msa.store = T.store 
WHERE min_msa.msa_income = msa.msa_income OR max_msa.msa_income = msa.msa_income
GROUP BY T.store

-- The store with the highest median msa_income was in Spanish Fort, AL. It had a lower average daily revenue than the store with the lowest median msa_income, which was in McAllen, TX.

---------------
-- Question 9
---------------
-- Divide the msa_income groups up so that msa_incomes between 1 and 20,000 are labeled 'low', msa_incomes between 20,001 and 30,000 are labeled 'med-low', msa_incomes between 30,001 and 40,000 are labeled 'med-high', and msa_incomes between 40,001 and 60,000 are labeled 'high'. Which of these groups has the highest average daily revenue (as defined in Teradata Week 5 Exercise Guide) per store?

SELECT 	CASE 
		WHEN msa.msa_income >0 AND msa.msa_income <=20000 THEN 'low'
		WHEN msa.msa_income >20000 AND msa.msa_income <=30000 THEN 'med-low'
		WHEN msa.msa_income >30000 AND msa.msa_income <=40000 THEN 'med-high'
		WHEN msa.msa_income >40000 AND msa.msa_income <=60000 THEN 'high'
 
		END AS ranking,
		SUM(daily_revenue) / SUM(num_days) AS avg_daily_revenue
FROM (	
	SELECT store, EXTRACT(MONTH FROM saledate) AS dm, EXTRACT (YEAR FROM saledate) AS dy, COUNT(DISTINCT saledate) AS num_days, SUM(amt) AS daily_revenue, EXTRACT(YEAR FROM saledate)||EXTRACT(MONTH FROM saledate) AS dym
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY store, dm, dy
	HAVING num_days >= 20 AND dym <> '2005 8') AS T
JOIN store_msa AS msa
ON msa.store = T.store
GROUP BY ranking;
-- low 34637.15

---------------
-- Question 10
---------------
-- Divide stores up so that stores with msa populations between 1 and 100,000 are labeled 'very small', stores with msa populations between 100,001 and 200,000 are labeled 'small', stores with msa populations between 200,001 and 500,000 are labeled 'med_small', stores with msa populations between 500,001 and 1,000,000 are labeled 'med_large', stores with msa populations between 1,000,001 and 5,000,000 are labeled “large”, and stores with msa_population greater than 5,000,000 are labeled “very large”. What is the average daily revenue (as defined in Teradata Week 5 Exercise Guide) for a store in a “very large” population msa?

SELECT 	CASE 
		WHEN msa.msa_pop >0 AND msa.msa_pop <=100000 THEN 'very small'
		WHEN msa.msa_pop >100000 AND msa.msa_pop <=200000 THEN 'small'
		WHEN msa.msa_pop >200000 AND msa.msa_pop <=500000 THEN 'med-small'
		WHEN msa.msa_pop >500000 AND msa.msa_pop <=1000000 THEN 'med_large'
 		WHEN msa.msa_pop >1000000 AND msa.msa_pop <=5000000 THEN 'large'
 		WHEN msa.msa_pop >5000000 THEN 'very large'
		END AS ranking,
		SUM(daily_revenue) / SUM(num_days) AS avg_daily_revenue
FROM (	
	SELECT store, EXTRACT(MONTH FROM saledate) AS dm, EXTRACT (YEAR FROM saledate) AS dy, COUNT(DISTINCT saledate) AS num_days, SUM(amt) AS daily_revenue, EXTRACT(YEAR FROM saledate)||EXTRACT(MONTH FROM saledate) AS dym
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY store, dm, dy
	HAVING num_days >= 20 AND dym <> '2005 8') AS T
JOIN store_msa AS msa
ON msa.store = T.store
GROUP BY ranking
ORDER BY avg_daily_revenue;
-- very large 25619.48

---------------
-- Question 11
---------------
-- Which department in which store had the greatest percent increase in average daily sales revenue from November to December, and what city and state was that store located in? Only examine departments whose total sales were at least $1,000 in both November and December.

SELECT	s.store,	s.city,	s.state,	d.deptdesc, sum(case	when	extract(month	from	saledate)=11	then	amt	
end)	as	November,
COUNT(DISTINCT	(case	WHEN	EXTRACT(MONTH	from	saledate)	='11'	then	saledate	END))	as	Nov_numdays,
sum(case	when	extract(month	from	saledate)=12 then	amt	end)	as	December,
COUNT(DISTINCT	(case	WHEN	EXTRACT(MONTH	from	saledate)	='12'	then	saledate	END))	as	Dec_numdays,
((December/Dec_numdays)-(November/Nov_numdays))/(November/Nov_numdays)*100	AS	bump
FROM	trnsact	t	JOIN	strinfo	s
ON	t.store=s.store	JOIN	skuinfo	si
ON	t.sku=si.sku	JOIN	deptinfo	d
ON	si.dept=d.dept
WHERE	t.stype='P'	and	t.store||EXTRACT(YEAR	from	t.saledate)||EXTRACT(MONTH	from	t.saledate)	IN
(SELECT	store||EXTRACT(YEAR	from	saledate)||EXTRACT(MONTH	from	saledate)
FROM	trnsact	
GROUP	BY	store,	EXTRACT(YEAR	from	saledate),	EXTRACT(MONTH	from	saledate)
HAVING	COUNT(DISTINCT	saledate)>=	20)
GROUP	BY	s.store,	s.city,	s.state,	d.deptdesc
HAVING	November	>	1000	AND	December	>	1000
ORDER	BY	bump	DESC;
-- Louisvl department, Salina,	KS


---------------
-- Question 12
---------------
-- Which department within a particular store had the greatest decrease in average daily sales revenue from August to September, and in what city and state was that store located?

SELECT T2.store, T2.dept, deptinfo.deptdesc, msa.city, msa.state, T2.change
FROM (
	SELECT T.store, T.dept,
		SUM(CASE WHEN T.dm=8 THEN T.num_days END) AS aug_day_sum,
		SUM(CASE WHEN T.dm=9 THEN T.num_days END) AS sept_day_sum,
		SUM(CASE WHEN T.dm=8 THEN T.daily_revenue END) AS aug_rev_sum,
		SUM(CASE WHEN T.dm=9 THEN T.daily_revenue END) AS sept_rev_sum,
		aug_rev_sum / sept_day_sum AS y,
	 	sept_rev_sum / sept_day_sum AS x,
		y-x AS change
	FROM (
		SELECT store, skuinfo.dept,
			EXTRACT(MONTH FROM saledate) AS dm, 
			EXTRACT (YEAR FROM saledate) AS dy, 
			COUNT(DISTINCT saledate) AS num_days, 
			SUM(amt) AS daily_revenue
		FROM trnsact
		JOIN skuinfo
		ON trnsact.sku = skuinfo.sku  
		WHERE stype = 'P'
		GROUP BY store, dept, dm, dy
		HAVING num_days >= 20 AND dm IN (8,9) AND dy <> 2005) AS T
	GROUP BY T.store, T.dept) AS T2
JOIN store_msa AS msa
ON T2.store = msa.store
JOIN deptinfo
ON T2.dept = deptinfo.dept
WHERE T2.change IS NOT NULL
ORDER BY T2.change DESC;

-- Louisville, KY

---------------
-- Question 13
---------------
-- Identify which department, in which city and state of what store, had the greatest DECREASE in the number of items sold from August to September. How many fewer items did that department sell in September compared to August?

SELECT T2.store, T2.dept, deptinfo.deptdesc, msa.city, msa.state, T2.change
FROM (
	SELECT T.store, T.dept,
		SUM(CASE WHEN T.dm=8 THEN T.num_items END) AS aug_day_sum,
		SUM(CASE WHEN T.dm=9 THEN T.num_items END) AS sept_day_sum,
		aug_day_sum - sept_day_sum AS change
	FROM (
		SELECT store, skuinfo.dept,
			EXTRACT(MONTH FROM saledate) AS dm, 
			EXTRACT (YEAR FROM saledate) AS dy, 
			COUNT(DISTINCT saledate) AS num_days, 
			SUM(quantity) AS num_items
		FROM trnsact
		JOIN skuinfo
		ON trnsact.sku = skuinfo.sku  
		WHERE stype = 'P'
		GROUP BY store, dept, dm, dy
		HAVING num_days >= 20 AND dm IN (8,9) AND dy <> 2005) AS T
	GROUP BY T.store, T.dept) AS T2
JOIN store_msa AS msa
ON T2.store = msa.store
JOIN deptinfo
ON T2.dept = deptinfo.dept
WHERE T2.change IS NOT NULL
ORDER BY T2.change DESC;
-- 9103 800 CLINIQUE LOUISVILLE KY 13491

---------------
-- Question 14
---------------
-- For each store, determine the month with the minimum average daily revenue (as defined in Teradata Week 5 Exercise Guide) . For each of the twelve months of the year, count how many stores' minimum average daily revenue was in that month. During which month(s) did over 100 stores have their minimum average daily revenue?

SELECT T.dm, COUNT(DISTINCT T.store)
FROM (
	SELECT store, 
		EXTRACT(MONTH FROM saledate) AS dm, 
		EXTRACT (YEAR FROM saledate) AS dy, 
		COUNT(DISTINCT saledate) AS num_days, 
		SUM(amt) AS daily_revenue, 
		daily_revenue / num_days AS avg_daily_rev, 
		EXTRACT(YEAR FROM saledate)||EXTRACT(MONTH FROM saledate) AS dym, 
		RANK() OVER(PARTITION BY store ORDER BY avg_daily_rev ASC) AS ranking
		FROM trnsact
		WHERE stype = 'P'
		GROUP BY store, dm, dy
		HAVING num_days >= 20 AND dym <> '2005 8') AS T
WHERE T.ranking = 1
GROUP BY T.dm;
-- 8 122

---------------
-- Question 15
---------------
-- Write a query that determines the month in which each store had its maximum number of sku units returned. During which month did the greatest number of stores have their maximum number of sku units returned?

SELECT T.dm, COUNT(DISTINCT T.store)
FROM (
	SELECT store, 
		EXTRACT(MONTH FROM saledate) AS dm, 
		EXTRACT (YEAR FROM saledate) AS dy, 
		COUNT(DISTINCT saledate) AS num_days, 
		SUM(quantity) AS daily_returns, 
		EXTRACT(YEAR FROM saledate)||EXTRACT(MONTH FROM saledate) AS dym, 
		RANK() OVER(PARTITION BY store ORDER BY daily_returns DESC) AS ranking
		FROM trnsact
		WHERE stype = 'R'
		GROUP BY store, dm, dy
		HAVING num_days >= 20 AND dym <> '2005 8') AS T
WHERE T.ranking = 1
GROUP BY T.dm;
-- 12
