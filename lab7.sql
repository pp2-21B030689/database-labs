-- 1.

-- a. Increments given values by 1 and returns it.
CREATE or REPLACE FUNCTION inc(num integer) RETURNS integer AS $$
    BEGIN
    RETURN num + 1;
    END; $$
    LANGUAGE plpgsql;

SELECT inc(1);

-- b. Returns sum of 2 numbers.
CREATE or REPLACE FUNCTION sum(a integer, b integer) RETURNS integer AS $$
    BEGIN
    RETURN a + b;
    END; $$
    LANGUAGE plpgsql;

SELECT sum(2, 5);

-- c. Returns true or false if numbers are divisible by 2.
CREATE or REPLACE FUNCTION isEven(a integer) RETURNS bool AS $$
    BEGIN
    RETURN (a % 2 = 0);
    END; $$
    LANGUAGE plpgsql;

SELECT isEven(3);

-- d. Checks some password for validity
CREATE or REPLACE FUNCTION isValid(password varchar) RETURNS bool AS $$
    BEGIN
    RETURN length(password) >= 6;
    END; $$
    LANGUAGE plpgsql;

SELECT isValid('qwrty');

-- e. Returns two outputs, but has one input.
CREATE or REPLACE FUNCTION rootAndSquare(number double precision, out root double precision, out square numeric) AS $$
    BEGIN
        root := power(number, 0.5);
        square := power(number, 2);
    END; $$
    LANGUAGE plpgsql;

SELECT rootAndSquare(3);

-- create table
CREATE TABLE employees (
    id integer primary key ,
    name varchar(255),
    date_of_birth date,
    age integer,
    salary integer,
    workexperience integer,
    discount integer
);

-- 2.
-- a. Return timestamp of the occurred action within the database.
create or replace function func_triggerA() returns trigger
    LANGUAGE PLPGSQL AS $$
    BEGIN
        insert into logsA values (NEW.id, now());
        return NEW;
    END; $$;
create table logsA (id integer, time timestamp);
CREATE or replace TRIGGER triggerA BEFORE INSERT on employees FOR EACH statement EXECUTE PROCEDURE func_triggerA();

-- b. Computes the age of a person when persons’ date of birth is inserted.
create or replace function func_triggerB() returns trigger
    LANGUAGE PLPGSQL AS $$
    BEGIN
        NEW.age = extract(year from now()) - extract(year from NEW.date_of_birth);
        return NEW;
    END; $$;
CREATE or replace TRIGGER triggerB BEFORE INSERT on employees FOR EACH ROW EXECUTE PROCEDURE func_triggerB();

-- c. Adds 12% tax on the price of the inserted item
create table tableC (price double precision);
create or replace function func_triggerC() returns trigger
    LANGUAGE PLPGSQL AS $$
    BEGIN
        NEW.price = NEW.price * 1.12;
        return NEW;
    END; $$;
CREATE or replace TRIGGER triggerC BEFORE INSERT on tableC FOR EACH ROW EXECUTE PROCEDURE func_triggerC();

INSERT INTO tableC VALUES (100);
SELECT * from tableC;

-- d. Prevents deletion of any row from only one table.
create or replace function func_triggerD() returns trigger
    LANGUAGE PLPGSQL AS $$
    BEGIN
        raise exception using message = 'Don`t do it';
    END $$;
CREATE or replace TRIGGER triggerD BEFORE DELETE on employees FOR EACH ROW EXECUTE PROCEDURE func_triggerD();

DELETE FROM employees WHERE id = 1;

-- e. Launches functions  1.d and 1.e.
create table tableE (isValid bool, root double precision, square numeric);
create or replace function func_triggerE() returns trigger
    LANGUAGE PLPGSQL AS $$
    BEGIN
        NEW.isValid := isValid('1224');
        NEW.root := (SELECT root from rootAndSquare(1));
        NEW.square := (SELECT square from rootAndSquare(1));
        return NEW;
    END $$;
CREATE or replace TRIGGER triggerE BEFORE INSERT on tableE FOR EACH ROW EXECUTE PROCEDURE func_triggerE();

INSERT INTO tableE VALUES (true, 0, 0);
SELECT * from tableE;

-- 3.
-- a. Increases salary by 10% for every 2 years of work experience
-- and provides 10% discount and after 5 years adds 1% to the discount.
CREATE or REPLACE PROCEDURE procA(employee_id numeric) language PLPGSQL as $$
    BEGIN
        UPDATE employees SET salary = salary * 1.1 * (workexperience/2),
                             discount = 10
                         WHERE id = employee_id;
        UPDATE employees SET discount = discount + 1 WHERE id = employee_id and workexperience >= 5;
    END; $$;

-- b. After reaching 40 years, increase salary by 15%. If work experience
-- is more than 8 years, increase salary for 15% of the already increased
-- value for work experience and provide a constant 20% discount.
CREATE or REPLACE PROCEDURE procB(employee_id numeric) language PLPGSQL as $$
    BEGIN
        UPDATE employees SET salary = salary * 1.15 WHERE id = employee_id and age >= 40;
        UPDATE employees SET salary = salary * 1.15, discount = 20 WHERE id = employee_id and workexperience >= 8;
    END; $$;