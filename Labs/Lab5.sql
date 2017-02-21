-- 1
SELECT city
FROM agents
inner join orders 
	on agents.aid = orders.aid
WHERE cid = 'c006';

-- 2
SELECT DISTINCT orders.pid
FROM orders
inner join customers
	on customers.cid = orders.cid AND customers.city = 'Kyoto'
full join orders orders2
on orders.aid = orders2.aid
WHERE orders.pid is not null
order by orders.pid;


-- 3
SELECT name
FROM customers
WHERE cid NOT in (SELECT cid
                  FROM orders);
                  
-- 4
SELECT name
FROM customers
left outer join orders
	on customers.cid = orders.cid
WHERE orders.cid IS null;

-- 5
SELECT DISTINCT customers.name, agents.name
FROM customers
inner join agents
	on customers.city = agents.city
inner join orders
	on customers.cid = orders.cid 
    AND agents.aid = orders.aid;
    
-- 6
SELECT customers.name, agents.name, customers.city
FROM customers
inner join agents
	on customers.city = agents.city;
    
-- 7
SELECT DISTINCT customers.name, customers.city
FROM customers
inner join products
	on customers.city = (SELECT city
                         FROM products
                         GROUP BY city
                         ORDER BY count(*) ASC
                         LIMIT 1)