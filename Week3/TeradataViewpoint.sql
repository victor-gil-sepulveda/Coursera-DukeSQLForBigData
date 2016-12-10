DATABASE ua_dillards;

HELP TABLE deptinfo;

HELP COLUMN deptinfo.dept;

-- Outputs the table sql schema
-- btw, comments must have this format
-- SHOW TABLE deptinfo;

----------------
-- Question 1 a
----------------
-- Number of different skus
SELECT COUNT(DISTINCT sku) 
FROM skuinfo;

SELECT COUNT(DISTINCT sku) 
FROM trnsact;

SELECT COUNT(DISTINCT sku) 
FROM skstinfo;

-- Number of shared skus
SELECT COUNT(DISTINCT skuinfo.sku) 
FROM skuinfo
INNER JOIN trnsact
ON skuinfo.sku = trnsact.sku;
--714499

SELECT COUNT(DISTINCT trnsact.sku) 
FROM trnsact
INNER JOIN skstinfo
ON trnsact.sku = skstinfo.sku;
--542513

SELECT COUNT(DISTINCT trnsact.sku) 
FROM trnsact
INNER JOIN skstinfo
ON trnsact.sku = skstinfo.sku;
-- 542513

-- Question 1 b
SELECT COUNT(*)
FROM skstinfo
INNER JOIN trnsact
ON trnsact.sku = skstinfo.sku AND trnsact.store = skstinfo.store;
-- 68578056

----------------
-- Question 2 a
----------------
SELECT COUNT(DISTINCT store) 
FROM strinfo;
--453

SELECT COUNT(DISTINCT store) 
FROM skstinfo;
--357

SELECT COUNT(DISTINCT store) 
FROM store_msa;
--333

SELECT COUNT(DISTINCT store) 
FROM trnsact;
-- 332

-- Question 2 b (partial)
SELECT count(DISTINCT strinfo.store)
FROM strinfo
JOIN skstinfo ON strinfo.store = skstinfo.store
JOIN store_msa ON strinfo.store = store_msa.store
JOIN trnsact ON strinfo.store = trnsact.store;

----------------
-- Question 3
----------------
SELECT *
FROM trnsact
LEFT JOIN skstinfo
ON trnsact.sku = skstinfo.sku
WHERE skstinfo.sku IS NULL;

----------------
-- Question 4
----------------
-- profit = revenue - cost 
SELECT *
FROM trnsact
WHERE trnsact.amt <> trnsact.sprice;
-- amt = sprice * quantity

-- I just investigated a bit about the product info data
SELECT *
FROM skstinfo
WHERE sku = 3996660;

-- It was impossible for me to solve this one without
-- using more than one query. Also a formatting clause
-- must be used in order to get the decimals 
SELECT register, AVG(profit) (DECIMAL (10,5))
FROM
	(SELECT register, SUM((trnsact.sprice - skstinfo.cost)*trnsact.quantity) as profit
	FROM skstinfo
	JOIN trnsact
	ON skstinfo.sku = trnsact.sku AND skstinfo.store = trnsact.store
	WHERE trnsact.stype = 'P' AND trnsact.sprice <> 0
	GROUP BY saledate, register) AS T
GROUP BY register;
-- result is not completely equal to the one expected: 
-- 10779.20 vs 10762.11

----------------
-- Question 5
----------------
-- On what day was the total value (in $) of returned goods the greatest?
SELECT TOP 1 saledate, SUM(trnsact.amt) AS total_returned
FROM trnsact
WHERE trnsact.stype = 'R'
GROUP BY saledate
ORDER BY total_returned DESC;
-- 04/12/27

-- On what day was the total number of individual returned items the greatest?  
SELECT TOP 1 saledate, COUNT(trnsact.quantity) AS num_returned
FROM trnsact
WHERE trnsact.stype = 'R'
GROUP BY saledate
ORDER BY num_returned DESC;
--05/02/26

----------------
-- Question 6
----------------
-- What is the maximum price paid for an item in our database?  
SELECT MAX(trnsact.sprice)
FROM trnsact
WHERE trnsact.stype = 'P';
-- 6017.00

-- What is the minimum price paid for an item in our database? 
-- What is the maximum price paid for an item in our database?  
SELECT MIN(trnsact.sprice)
FROM trnsact
WHERE trnsact.stype = 'P' AND trnsact.sprice <> 0;
-- 0.01

----------------
-- Question 7
----------------
-- How many departments have more than 100 brands associated with them, 
-- and what are their descriptions?
SELECT COUNT(DISTINCT skuinfo.brand) AS num_brands
FROM deptinfo
JOIN skuinfo
ON deptinfo.dept = skuinfo.dept
GROUP BY skuinfo.dept
HAVING num_brands > 100;
-- 3

----------------
-- Question 8
----------------
-- Write a query that retrieves the department descriptions of each of the skus in the skstinfo table.
SELECT UNIQUE skuinfo.sku, deptinfo.deptdesc
FROM skstinfo
JOIN skuinfo
ON skstinfo.sku = skuinfo.sku
JOIN deptinfo
ON skuinfo.dept = deptinfo.dept;

----------------
-- Question 9
----------------
-- What department (with department description), brand, style, and color had the greatest total 
-- value of returned items? 
SELECT deptinfo.dept, COUNT(*) AS total_returns
FROM trnsact
JOIN skuinfo
ON trnsact.sku = skuinfo.sku
JOIN deptinfo
ON skuinfo.dept = deptinfo.dept
WHERE trnsact.stype = 'R'
GROUP BY skuinfo.brand
ORDER BY total_returns DESC;

SELECT TOP 1 skuinfo.brand, COUNT(*) AS total_returns
FROM trnsact
JOIN skuinfo
ON trnsact.sku = skuinfo.sku
WHERE trnsact.stype = 'R'
GROUP BY skuinfo.brand
ORDER BY total_returns DESC;

----------------
-- Question 10
----------------
-- In what state and zip code is the store that had the greatest total revenue 
-- during the time period monitored in our dataset? 
SELECT TOP 1 strinfo.zip, SUM((trnsact.sprice - skstinfo.cost)*trnsact.quantity) as profit
FROM trnsact
JOIN strinfo
ON strinfo.store = trnsact.store 
JOIN skstinfo
ON skstinfo.sku = trnsact.sku AND skstinfo.store = trnsact.store
WHERE trnsact.stype = 'P' AND trnsact.sprice <> 0
GROUP BY strinfo.zip
ORDER BY profit DESC;


