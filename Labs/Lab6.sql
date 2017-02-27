-- 1
SELECT name, city
FROM customers
WHERE city in (SELECT city
               FROM products
               GROUP BY city
               ORDER BY count(*) DESC
               LIMIT 1);
               
-- 2
SELECT name
FROM products
WHERE priceUSD > (SELECT AVG(priceUSD)
                  FROM products)
ORDER BY name DESC;

-- 3
SELECT  customers.name, orders.pid, orders.totalUSD
FROM orders
LEFT OUTER JOIN customers
ON orders.cid = customers.cid
ORDER BY totalUSD ASC;

-- 4
SELECT customers.name, SUM(COALESCE(totalUSD, 0))
FROM customers
LEFT OUTER JOIN orders
ON customers.cid = orders.cid
GROUP BY customers.cid -- How many people grouped by name & combined ACMEs? I almost did...
ORDER BY customers.name ASC;

-- 5
SELECT customers.name as customer, products.name AS product, agents.name AS agent
FROM orders
LEFT OUTER JOIN customers
ON orders.cid = customers.cid
LEFT OUTER JOIN products
ON orders.pid = products.pid
LEFT OUTER JOIN agents
ON orders.aid = agents.aid
WHERE orders.cid in (SELECT cid
              		 FROM orders
              		 WHERE aid in (SELECT aid
                            	   FROM agents
                                   WHERE city = 'Newark'));
                                   
-- 6
SELECT orders.*, ((orders.qty * (products.priceUSD)) * (1 - (customers.discount / 100))) AS calcTotal
FROM orders
LEFT OUTER JOIN products
ON orders.pid = products.pid
LEFT OUTER JOIN customers
ON orders.cid = customers.cid
WHERE totalUSD != ((orders.qty * (products.priceUSD)) * (1 - (customers.discount / 100)));

-- 7 
/* The difference between left and right outer joins comes down to which
table is used as the starting/base table. Whichever is the starting table
has all its rows selected, and then only rows from the second table that
fufill the ON statement are joined.

Essentially, the LEFT/RIGHT defines which table is that starting point.
If we use a LEFT join, then the table to the left of the join statement is
the base, so all of its rows are taken. Here is an example:             */

SELECT customers.name, orders.ordNumber
FROM customers LEFT outer join orders
--   LEFT TBL                 RIGHT TBL
ON customers.cid = orders.cid; 

/* Notice how Weyland is joined to a [null]. This is because there are no
orders placed by Weyland. Since we started with the customers table, it is
included even though there is no match in the orders table. What about with
a right join? */

SELECT customers.name, orders.ordNumber
FROM customers RIGHT outer join orders
ON customers.cid = orders.cid;

/* This time, Weyland doesn't appear at all. This is because we started with
the right table, orders. In this case, each order is joined with the customer
who placed it. Since customers who haven't placed an order won't appear in
the orders table at all, there will be nowhere to join them. */
