-- 1
SELECT ordnumber, totalusd
FROM orders;

-- 2
SELECT name, city
FROM agents
WHERE name = 'Smith';

-- 3
SELECT pid, name, priceusd
FROM products
WHERE quantity > 200100;

-- 4
SELECT name, city
FROM customers
WHERE city = 'Duluth';

-- 5
SELECT name, city
FROM agents
WHERE city != 'New York'
  AND city != 'Duluth';

-- 6
SELECT *
FROM products
WHERE city != 'Dallas'
  AND city != 'Duluth'
  AND priceusd >= 1;

-- 7
SELECT *
FROM orders
WHERE month = 'Feb'
   OR month = 'May';

-- 8
SELECT *
FROM orders
WHERE month = 'Feb'
AND totalusd >= 600;

-- 9
SELECT *
FROM orders
WHERE cid = 'c005';