DATABASE ua_dillards;

HELP TABLE deptinfo;

HELP COLUMN deptinfo.dept;

-- Outputs the table sql schema
-- btw, comments must have this format
SHOW TABLE deptinfo;

SELECT TOP 10 *
FROM strinfo;

SELECT TOP 10 *
FROM strinfo
ORDER BY city ASC;

SELECT TOP 10 *
FROM strinfo
ORDER BY city DESC;

SELECT *
FROM strinfo
SAMPLE 10;

SELECT *
FROM strinfo
SAMPLE .1;

-- Ex. 2
SELECT *
FROM skuinfo
SAMPLE 30;

-- Ex. 3
-- In order to check the comment:
-- The department descriptions seem to represent brand names.  However, if you look at 
-- entries in the skuinfo table from only one department, you will see that many brands are 
-- in the same department.  
SELECT DISTINCT dept, brand
FROM skuinfo
ORDER BY dept ASC, brand ASC;

-- Ex. 4
SELECT *
FROM trnsact
WHERE sprice <> amt
SAMPLE 10;
-- it looks like sprice is the price for a single unit, quantity is the number of units, and amt the amount paid.

-- Ex. 5
SELECT *
FROM trnsact
WHERE orgprice = 0
SAMPLE 10;

SELECT *
FROM skstinfo
WHERE cost = 0 AND retail = 0
SAMPLE 10;

SELECT *
FROM skstinfo
WHERE cost > retail 
SAMPLE 10;
-- Ex. 6

-- Using IN
SHOW TABLE trnsact;
SELECT *
FROM trnsact
WHERE mic IN('097', '205', '511');

-- Using BETWEEN
SELECT *
FROM trnsact
WHERE store BETWEEN 1000 and 2000;

-- Using dates
-- It looks like a cast is mandatory, at least in this case
SELECT *
FROM trnsact
WHERE saledate > CAST ('2005-01-01' AS DATE)
SAMPLE 100;

