-- 5
HELP TABLE strinfo;

-- 6
SELECT COUNT(city) FROM strinfo WHERE city IS NULL;
SELECT COUNT(state) FROM strinfo WHERE state IS NULL; 
SELECT COUNT(zip) FROM strinfo WHERE zip IS NULL; 

-- 7
HELP TABLE trnsact;

SELECT TOP 1 orgprice
FROM trnsact
WHERE sku=3631365
ORDER BY orgprice DESC;

SELECT MAX(orgprice)
FROM trnsact
WHERE sku=3631365;

-- 8
HELP TABLE skuinfo;

SELECT TOP 1 color
FROM skuinfo
WHERE brand='LIZ CLAI'
ORDER BY sku DESC;

-- 10

HELP TABLE trnsact;

SELECT TOP 1 sku
FROM trnsact
ORDER BY orgprice DESC;

-- This is a bit faster, I must investigate why
SELECT TOP 1 trnsact.sku
FROM (SELECT MAX(orgprice) AS max_orgprice
      FROM trnsact) as T, trnsact
WHERE orgprice = T.max_orgprice;

-- 11
SELECT DISTINCT state
FROM strinfo;

-- 12
SELECT COUNT(deptdesc)
FROM deptinfo
WHERE deptdesc LIKE 'e%';

-- 13
SELECT TOP 1 saledate, (orgprice - sprice) AS margin
FROM trnsact
WHERE orgprice <> sprice
ORDER BY saledate ASC, margin DESC;

-- 14
SELECT TOP 1 register
FROM trnsact
WHERE saledate BETWEEN CAST('2004-08-01' AS DATE) AND CAST('2004-08-10' AS DATE) 
ORDER BY orgprice DESC, sprice DESC;

-- 15
SELECT DISTINCT brand
FROM skuinfo
WHERE brand LIKE '%LIZ%';

-- 16
SELECT TOP 1 store, city
FROM store_msa
WHERE city IN ('little rock','memphis','tulsa')
ORDER BY store ASC;
