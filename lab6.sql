-- 1
-- a. combine each row of dealer table with each row of client table
SELECT * from dealer LEFT JOIN client c on dealer.id = c.dealer_id;

-- c. find the dealer and client who belongs to same city
SELECT * from dealer LEFT JOIN client c on dealer.id = c.dealer_id
         where dealer.location = c.city;

-- d. find sell id, amount, client name, city those sells where sell amount exists between
-- 100 and 500
SELECT sell.id, sell.amount, client.name, client.city from sell
    LEFT JOIN client on client.id = sell.client_id
    where sell.amount between 100 and 500;

-- e. find dealers who works either for one or more client or not yet join under any of
-- the clients
SELECT * from dealer;

-- f. find the dealers and the clients he service, return client name, city, dealer name,
-- commission(charge).
SELECT client.name, client.city, dealer.name, dealer.charge from dealer
    LEFT JOIN client on dealer.id = client.dealer_id;

-- g. find client name, client city, dealer, commission those dealers who received a
-- commission from the sell more than 12%
SELECT client.name, client.city, dealer.name, dealer.charge from dealer
    LEFT JOIN client on dealer.id = client.dealer_id
    where dealer.charge > 0.12;

-- h. make a report with client name, city, sell id, sell date, sell amount, dealer name
-- and commission to find that either any of the existing clients haven’t made a
-- purchase(sell) or made one or more purchase(sell) by their dealer or by own.
SELECT client.name as "Имя клиента", client.city as "Город клиента", sell.id as "ID сделки", sell.date as "Дата сделки", dealer.name as "Имя дилера", dealer.charge as "Коммисия" from dealer
    LEFT JOIN client on dealer.id = client.dealer_id
    LEFT JOIN sell on client.id = sell.client_id
    ORDER BY client.name;

-- i. find dealers who either work for one or more clients. The client may have made,
-- either one or more purchases, or purchase amount above 2000 and must have a
-- grade, or he may not have made any purchase to the associated dealer. Print
-- client name, client grade(priority), dealer name, sell id, sell amount
SELECT client.name, client.priority, dealer.name, sell.id, sell.amount from dealer
    LEFT JOIN client on dealer.id = client.dealer_id
    LEFT JOIN sell on client.id = sell.client_id;


-- 2
-- a. count the number of unique clients, compute average and total purchase
-- amount of client orders by each date.
CREATE VIEW lab6A AS SELECT sell.date, count(DISTINCT client_id), avg(sell.amount), sum(sell.amount) from sell
    GROUP BY sell.date;

-- b. find top 5 dates with the greatest total sell amount
CREATE VIEW lab6B AS SELECT date, sum(amount) from sell
    GROUP BY date
    ORDER BY sum(amount) DESC LIMIT 5;

-- c. count the number of sales, compute average and total amount of all
-- sales of each dealer
CREATE VIEW lab6C AS SELECT dealer_id, count(id), avg(amount), sum(amount) from sell
    GROUP BY dealer_id;

-- d. compute how much all dealers earned from charge(total sell amount *
-- charge) in each location
CREATE VIEW lab6D AS SELECT dealer.location, sum(sell.amount * dealer.charge) from dealer LEFT JOIN sell on dealer.id = sell.dealer_id
    GROUP BY dealer.location;

-- e. compute number of sales, average and total amount of all sales dealers
-- made in each location
CREATE VIEW lab6E AS SELECT dealer.location, avg(sell.amount), sum(sell.amount) from dealer LEFT JOIN sell on dealer.id = sell.dealer_id
    GROUP BY dealer.location;

-- f. compute number of sales, average and total amount of expenses in
-- each city clients made
CREATE VIEW lab6F AS SELECT client.city, count(sell.id), avg(sell.amount), sum(sell.amount) from client LEFT JOIN sell on client.id = sell.client_id
    GROUP BY client.city;

-- g. Find cities where total expenses more than total amount of sales in locations
CREATE VIEW lab6G AS SELECT dealer.location from dealer LEFT JOIN sell on dealer.id = sell.dealer_id
    GROUP BY dealer.location
    HAVING sum(sell.amount) + sum(sell.amount) > (SELECT sum(sell.amount) from dealer LEFT JOIN sell on dealer.id = sell.dealer_id);
