-- 1
SELECT city
FROM agents
WHERE aid in (SELECT aid
              FROM orders
              WHERE cid = 'c006');

-- 2
SELECT DISTINCT pid
FROM orders
WHERE aid in (SELECT aid
              FROM orders
              WHERE cid in (SELECT cid
                            FROM customers
                            WHERE city  = 'Kyoto'))
order by pid ASC;

-- 3
SELECT cid, name
FROM customers
WHERE cid NOT in (SELECT cid
                  FROM orders
                  WHERE aid = 'a01');
                  
-- 4
SELECT cid
FROM customers
WHERE cid in (SELECT cid
              FROM orders
              WHERE pid = 'p01')
AND cid in (SELECT cid
              FROM orders
              WHERE pid = 'p07');

-- 5
SELECT DISTINCT pid
FROM orders
WHERE cid NOT in (SELECT cid
              	  FROM orders
                  WHERE aid = 'a08')
ORDER BY pid DESC;

-- 6
SELECT name, discount, city
FROM customers
WHERE cid in (SELECT cid
              FROM orders
              WHERE aid in (SELECT aid
                            FROM agents
                            WHERE city in ('Tokyo', 'New York')));
                            
-- 7
SELECT *
FROM customers
WHERE discount in (SELECT discount
                   FROM customers
                   WHERE city in ('Duluth', 'London'));
                   
-- 8
/*
	Check constraints are tests that are run on either attributes or rows
to ensure the data inputted is acceptable. They are good for making sure your
data doesn't have any obvious errors, such as a test grade being a "G". The
advantage is that the database itself enforces this, and it's not just enforced
by some user-facing program that passes the data to the database.
	A good use of check constraints would be enforcing a set of letter grades
A grade field, or limiting the discount_usd to less than the price of a product.
These are good as they are rules that will not change. They also
	A bad use would be to check that a salesman's name matches a hardcoded list
of names. This would be bad because every time a new salesman is added, the
check needs to be manually updated.
*/