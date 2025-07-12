CREATE DATABASE Viviana_Mall;

USE Viviana_Mall
/*
-- ----------------------------------------------database Analysis--------------------------------------------------
T1  : Stores(store_id, store_name, category, floor_number, contact_number, email, opening_date, monthly_rent, is_active)
    - Master table for all stores in the mall. Includes basic details like store name, category (e.g., clothing, electronics), location (floor), rent, and operational status.

T2  : Employees(employee_id, first_name, last_name, store_id, position, salary, hire_date, birth_date, email, phone, gender)
    - Contains staff details for each store, including position, contact info, gender, and store association.

T3  : Customers(customer_id, first_name, last_name, email, phone, join_date, birth_date, address)
    - Holds registered customer information including their contact and joining details. Useful for customer profiling and loyalty programs.

T4  : Products(product_id, product_name, category_id, category_name, price, stock, brand, supplier, created_at)
    - Product catalog with pricing, brand, stock level, and supplier info. Allows tracking inventory and product listings.

T5  : Sales(sale_id, customer_id, product_id, employee_id, sale_date, quantity, unit_price, discount, payment_method)
    - Records individual sales transactions, including customer, product, seller, quantity, pricing, and mode of payment.
*/
-- table 1
-- create table
CREATE TABLE Stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    floor_number INT ,
    contact_number VARCHAR(15),
    email VARCHAR(100),
    opening_date DATE,
    monthly_rent DECIMAL(10,2),
    is_active BOOLEAN DEFAULT TRUE
);

-- insert records
INSERT INTO Stores VALUES 
(1, 'Fashion Haven', 'Apparel', 2, '9876543210', 'fashion@viviana.com', '2020-01-15', 50000.00, TRUE),
(2, 'Tech World', 'Electronics', 3, '9876543211', 'tech@viviana.com', '2019-11-20', 75000.00, TRUE),
(3, 'Gourmet Delight', 'Food', 1, '9876543212', 'gourmet@viviana.com', '2021-03-10', 40000.00, TRUE),
(4, 'Book Nook', 'Books', 2, '9876543213', 'books@viviana.com', '2020-07-05', 35000.00, TRUE),
(5, 'Home Essentials', 'Home Goods', 3, '9876543214', 'home@viviana.com', '2021-01-30', 45000.00, TRUE),
(6, 'Sports Zone', 'Sports', 4, '9876543215', 'sports@viviana.com', '2020-05-12', 55000.00, TRUE),
(7, 'Beauty Spot', 'Cosmetics', 1, '9876543216', 'beauty@viviana.com', '2021-02-18', 48000.00, TRUE),
(8, 'Toy Land', 'Toys', 4, '9876543217', 'toys@viviana.com', '2020-09-22', 38000.00, TRUE),
(9, 'Jewel Box', 'Jewelry', 2, '9876543218', 'jewelry@viviana.com', '2020-04-15', 60000.00, TRUE),
(10, 'Health Plus', 'Pharmacy', 1, '9876543219', 'pharmacy@viviana.com', '2021-01-10', 42000.00, TRUE);



-- 1. Add column for store area in sq. ft.
ALTER TABLE Stores ADD area_sqft INT;

-- 2. Modify category column to be NOT NULL
ALTER TABLE Stores MODIFY category VARCHAR(50) NOT NULL;

-- 3. Insert new store
INSERT INTO Stores VALUES 
(101, 'Trendy Wear', 'Apparel', 2, '9876543210', 'trendy@viviana.com', '2022-05-10', 55000.00, TRUE, 1200);

-- 4. Update monthly rent for a store
UPDATE Stores SET monthly_rent = 60000 WHERE store_id = 101;

-- 5. Delete inactive stores
DELETE FROM Stores WHERE is_active = FALSE;

-- 6. Select all stores on floor 2
SELECT * FROM Stores WHERE floor_number = 2;

-- 7. Begin transaction and commit after rent hike
START TRANSACTION;
UPDATE Stores SET monthly_rent = monthly_rent * 1.1 WHERE category = 'Electronics';
COMMIT;

-- 8. Rollback mistaken rent reset
START TRANSACTION;
UPDATE Stores SET monthly_rent = 0;
ROLLBACK;

-- 9. Grant SELECT, UPDATE on Stores to admin_user
GRANT SELECT, UPDATE ON Stores TO admin_user;

-- 10. Revoke DELETE from casual_user
REVOKE DELETE ON Stores FROM casual_user;

-- 11. List stores paying rent above average
SELECT * FROM Stores WHERE monthly_rent > (SELECT AVG(monthly_rent) FROM Stores);

-- 12. Use CASE to categorize store rent levels
SELECT store_name, monthly_rent,
    CASE
        WHEN monthly_rent >= 70000 THEN 'High Rent'
        WHEN monthly_rent BETWEEN 40000 AND 70000 THEN 'Medium Rent'
        ELSE 'Low Rent'
    END AS rent_level
FROM Stores;

-- 13. CONCAT floor and category
SELECT CONCAT('Floor ', floor_number, ' - ', category) AS location_tag FROM Stores;

-- 14. Use of ROUND for rent
SELECT store_name, ROUND(monthly_rent, -3) AS approx_rent FROM Stores;

-- 15. Use of LIKE for store name search
SELECT * FROM Stores WHERE store_name LIKE '%Mart%';

-- 16. Use of IN to filter categories
SELECT * FROM Stores WHERE category IN ('Apparel', 'Electronics');

-- 17. Use of COALESCE for contact number
SELECT store_name, COALESCE(contact_number, 'No Contact') AS contact FROM Stores;

-- 18. Alias for cleaner reporting
SELECT store_id AS ID, store_name AS Name, floor_number AS Floor FROM Stores;

-- 19. Find stores open more than 3 years
SELECT store_name, opening_date FROM Stores
WHERE DATEDIFF(CURDATE(), opening_date) > 1095;

-- 20. ORDER BY multiple fields
SELECT * FROM Stores ORDER BY floor_number, monthly_rent DESC;

-- 21. Join with Employees to find store staff
SELECT s.store_name, e.first_name, e.position
FROM Stores s
JOIN Employees e ON s.store_id = e.store_id;

-- 22. Subquery: Highest rent store per category
SELECT * FROM Stores s
WHERE monthly_rent = (
    SELECT MAX(monthly_rent) FROM Stores WHERE category = s.category
);

-- 23. View: Active Apparel stores
CREATE VIEW ActiveApparelStores AS
SELECT * FROM Stores WHERE category = 'Apparel' AND is_active = TRUE;

-- 24. CTE: Recent stores opened in last year
WITH RecentStores AS (
    SELECT * FROM Stores WHERE opening_date >= CURDATE() - INTERVAL 1 YEAR
)
SELECT * FROM RecentStores;

-- 25. Join with Sales (via Employees) to calculate revenue potential
SELECT st.store_name, COUNT(sl.sale_id) AS total_sales
FROM Stores st
JOIN Employees e ON st.store_id = e.store_id
JOIN Sales sl ON e.employee_id = sl.employee_id
GROUP BY st.store_id;

-- 26. Join with Products via Sales to get sold brands per store
SELECT st.store_name, pr.brand, COUNT(*) AS sold_count
FROM Stores st
JOIN Employees e ON st.store_id = e.store_id
JOIN Sales s ON e.employee_id = s.employee_id
JOIN Products pr ON s.product_id = pr.product_id
GROUP BY st.store_name, pr.brand;

-- 27. Subquery: Get stores above average rent on floor 1
SELECT * FROM Stores
WHERE floor_number = 1 AND monthly_rent > (
    SELECT AVG(monthly_rent) FROM Stores WHERE floor_number = 1
);

-- 28. Subquery: Find store(s) with max area
SELECT * FROM Stores
WHERE area_sqft = (SELECT MAX(area_sqft) FROM Stores);

-- 29. Join with Employees to count staff per store
SELECT st.store_id, st.store_name, COUNT(e.employee_id) AS staff_count
FROM Stores st
LEFT JOIN Employees e ON st.store_id = e.store_id
GROUP BY st.store_id;

-- 30. View for store contact directory
CREATE VIEW StoreDirectory AS
SELECT store_name, contact_number, email, floor_number FROM Stores;

-- 31. Function to calculate years of operation
DELIMITER //
CREATE FUNCTION store_age(opening DATE) RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, opening, CURDATE());
END //
DELIMITER ;

-- 32. Use store_age function
SELECT store_name, store_age(opening_date) AS years_open FROM Stores;

-- 33. Procedure to increase rent by category
DELIMITER //
CREATE PROCEDURE IncreaseRentByCategory(IN cat VARCHAR(50), IN percent DECIMAL(5,2))
BEGIN
    UPDATE Stores
    SET monthly_rent = monthly_rent * (1 + percent/100)
    WHERE category = cat;
END //
DELIMITER ;

-- 34. Call procedure
CALL IncreaseRentByCategory('Electronics', 10);

-- 35. Procedure to deactivate a store
DELIMITER //
CREATE PROCEDURE DeactivateStore(IN sid INT)
BEGIN
    UPDATE Stores SET is_active = FALSE WHERE store_id = sid;
END //
DELIMITER ;

-- 36. Execute deactivation
CALL DeactivateStore(101);

-- 37. Procedure to add a new store
DELIMITER //
CREATE PROCEDURE AddStore(
    IN sid INT, IN sname VARCHAR(100), IN cat VARCHAR(50), IN fl INT,
    IN contact VARCHAR(15), IN mail VARCHAR(100), IN od DATE, IN rent DECIMAL(10,2), IN active BOOL
)
BEGIN
    INSERT INTO Stores(store_id, store_name, category, floor_number, contact_number, email, opening_date, monthly_rent, is_active)
    VALUES (sid, sname, cat, fl, contact, mail, od, rent, active);
END //
DELIMITER ;

-- 38. Add a new store using procedure
CALL AddStore(102, 'ShoeHub', 'Footwear', 1, '9999999999', 'shoehub@viviana.com', '2023-08-01', 35000, TRUE);

-- 39. Procedure to fetch all active stores on a specific floor
DELIMITER //
CREATE PROCEDURE GetActiveStoresByFloor(IN floor INT)
BEGIN
    SELECT * FROM Stores WHERE is_active = TRUE AND floor_number = floor;
END //
DELIMITER ;

-- 40. Call it for floor 2
CALL GetActiveStoresByFloor(2);

-- 41. Count of stores per category
SELECT category, COUNT(*) AS num_stores FROM Stores GROUP BY category;

-- 42. Average rent by floor
SELECT floor_number, AVG(monthly_rent) AS avg_rent FROM Stores GROUP BY floor_number;

-- 43. Number of years open per store
SELECT store_name, TIMESTAMPDIFF(YEAR, opening_date, CURDATE()) AS years_open FROM Stores;

-- 44. Rent range per floor
SELECT floor_number, MIN(monthly_rent) AS min_rent, MAX(monthly_rent) AS max_rent
FROM Stores GROUP BY floor_number;

-- 45. Floor-wise active vs inactive stores
SELECT floor_number,
    SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END) AS active_stores,
    SUM(CASE WHEN is_active = FALSE THEN 1 ELSE 0 END) AS inactive_stores
FROM Stores
GROUP BY floor_number;

-- 46. Category with highest total rent
SELECT category, SUM(monthly_rent) AS total_rent
FROM Stores
GROUP BY category
ORDER BY total_rent DESC
LIMIT 1;

-- 47. Stores with missing email/contact
SELECT * FROM Stores WHERE email IS NULL OR contact_number IS NULL;

-- 48.Display Everthing from Tables
select * from Stores;

-- 49.Truncate table 
TRUNCATE TABLE Stores;

-- 50.Drop table
 DROP TABLE Stores;

-- table 2
-- create table
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    store_id INT REFERENCES Stores(store_id),
    position VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    birth_date DATE,
    email VARCHAR(100),
    phone VARCHAR(15),
    gender CHAR(1) CHECK (gender IN ('M', 'F', 'O'))
);

-- insert records

INSERT INTO Employees VALUES 
(101, 'Rahul', 'Sharma', 1, 'Store Manager', 45000.00, '2020-02-10', '1985-06-15', 'rahul@viviana.com', '9876543220', 'M'),
(102, 'Priya', 'Patel', 1, 'Sales Associate', 25000.00, '2020-03-15', '1992-09-22', 'priya@viviana.com', '9876543221', 'F'),
(103, 'Amit', 'Singh', 2, 'Store Manager', 50000.00, '2019-12-01', '1988-03-18', 'amit@viviana.com', '9876543222', 'M'),
(104, 'Neha', 'Gupta', 2, 'Technician', 35000.00, '2020-01-20', '1990-11-05', 'neha@viviana.com', '9876543223', 'F'),
(105, 'Vikram', 'Joshi', 3, 'Chef', 40000.00, '2021-04-05', '1987-07-30', 'vikram@viviana.com', '9876543224', 'M'),
(106, 'Ananya', 'Reddy', 4, 'Store Manager', 42000.00, '2020-08-12', '1989-04-25', 'ananya@viviana.com', '9876543225', 'F'),
(107, 'Rajesh', 'Kumar', 5, 'Sales Associate', 28000.00, '2021-02-15', '1993-01-10', 'rajesh@viviana.com', '9876543226', 'M'),
(108, 'Sneha', 'Iyer', 6, 'Fitness Trainer', 32000.00, '2020-06-20', '1991-08-15', 'sneha@viviana.com', '9876543227', 'F'),
(109, 'Arjun', 'Menon', 7, 'Beauty Consultant', 30000.00, '2021-03-01', '1994-05-22', 'arjun@viviana.com', '9876543228', 'M'),
(110, 'Divya', 'Nair', 8, 'Store Manager', 38000.00, '2020-10-05', '1986-12-08', 'divya@viviana.com', '9876543229', 'F');

-- 1. Add a new column to track performance rating
ALTER TABLE Employees ADD performance_rating DECIMAL(3,2);

-- 2. Rename the column phone to contact_number
ALTER TABLE Employees RENAME COLUMN phone TO contact_number;

-- 3. Update salary for employees hired before 2020
UPDATE Employees SET salary = salary * 1.1 WHERE hire_date < '2020-01-01';

-- 4. Delete employees with no store assigned (store_id IS NULL)
DELETE FROM Employees WHERE store_id IS NULL;

-- 5. Insert a new employee
INSERT INTO Employees VALUES (201, 'Amit', 'Joshi', 1, 'Cashier', 25000.00, '2024-05-01', '1995-09-10', 'amit.joshi@mall.com', '9998887776', 'M');

-- 6. Simple SELECT query with WHERE
SELECT * FROM Employees WHERE position = 'Manager';

-- 7. Commit salary changes for those promoted
BEGIN;
UPDATE Employees SET salary = salary + 5000 WHERE position = 'Supervisor';
COMMIT;

-- 8. Rollback an incorrect update
BEGIN;
UPDATE Employees SET salary = -1;
ROLLBACK;

-- 9. Revoke permission
REVOKE SELECT ON Employees FROM guest;

-- 10. Grant permission to HR
GRANT UPDATE, SELECT ON Employees TO hr_user;

-- 11. Employees earning above average salary
SELECT * FROM Employees WHERE salary > (SELECT AVG(salary) FROM Employees);

-- 12. CASE statement to label salary level
SELECT first_name, last_name,
    CASE 
        WHEN salary > 50000 THEN 'High'
        WHEN salary BETWEEN 30000 AND 50000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_grade
FROM Employees;

-- 13. CONCAT and UPPER
SELECT CONCAT(UPPER(first_name), ' ', UPPER(last_name)) AS full_name FROM Employees;

-- 14. Get age of employees
SELECT first_name, birth_date, TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS age FROM Employees;

-- 15. LIKE clause to find employee emails by domain
SELECT * FROM Employees WHERE email LIKE '%@gmail.com';

-- 16. IN operator for multiple positions
SELECT * FROM Employees WHERE position IN ('Manager', 'Salesperson');

-- 17. Use of COALESCE for nullable email
SELECT first_name, COALESCE(email, 'No Email') AS contact_email FROM Employees;

-- 18. Modulus operator for assigning shifts
SELECT employee_id, first_name, MOD(employee_id, 2) AS shift_type FROM Employees;

-- 19. Order by salary and hire date
SELECT * FROM Employees ORDER BY salary DESC, hire_date ASC;

-- 20. LIMIT and OFFSET for pagination
SELECT * FROM Employees ORDER BY employee_id LIMIT 5 OFFSET 10;

-- 21. Join Employees with Stores
SELECT e.first_name, e.last_name, s.store_name
FROM Employees e
JOIN Stores s ON e.store_id = s.store_id;

-- 22. Get employees working in "Electronics" stores
SELECT e.*
FROM Employees e
JOIN Stores s ON e.store_id = s.store_id
WHERE s.category = 'Electronics';

-- 23. Subquery: Employees with highest salary
SELECT * FROM Employees
WHERE salary = (SELECT MAX(salary) FROM Employees);

-- 24. View for active employees
CREATE VIEW ActiveEmployees AS
SELECT * FROM Employees WHERE salary IS NOT NULL AND store_id IS NOT NULL;

-- 25. CTE: Recent hires in last 6 months
WITH RecentHires AS (
    SELECT * FROM Employees WHERE hire_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
)
SELECT * FROM RecentHires;

-- 26. Correlated subquery: Employees earning more than avg in their store
SELECT * FROM Employees e
WHERE salary > (
    SELECT AVG(salary) FROM Employees WHERE store_id = e.store_id
);

-- 27. Join with Sales to count how many sales each employee made
SELECT e.employee_id, e.first_name, COUNT(s.sale_id) AS total_sales
FROM Employees e
JOIN Sales s ON e.employee_id = s.employee_id
GROUP BY e.employee_id;

-- 28. Use of EXISTS to check employees with sales
SELECT * FROM Employees e
WHERE EXISTS (
    SELECT 1 FROM Sales s WHERE s.employee_id = e.employee_id
);

-- 29. Nested subquery: Employees with more sales than average
SELECT * FROM Employees
WHERE employee_id IN (
    SELECT employee_id FROM Sales
    GROUP BY employee_id
    HAVING COUNT(*) > (
        SELECT AVG(sale_count) FROM (
            SELECT COUNT(*) AS sale_count FROM Sales GROUP BY employee_id
        ) AS avg_sales
    )
);

-- 30. Join with Products to show sales info per employee per brand
SELECT e.first_name, p.brand, COUNT(s.sale_id) AS brand_sales
FROM Employees e
JOIN Sales s ON e.employee_id = s.employee_id
JOIN Products p ON s.product_id = p.product_id
GROUP BY e.employee_id, p.brand;


-- 31. UDF to calculate age
DELIMITER //
CREATE FUNCTION calculate_age(birth_date DATE) RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, birth_date, CURDATE());
END //
DELIMITER ;

-- 32. Use UDF
SELECT first_name, calculate_age(birth_date) AS age FROM Employees;

-- 33. Stored Procedure to give annual bonus
DELIMITER //
CREATE PROCEDURE GiveAnnualBonus(IN bonus_amount DECIMAL(10,2))
BEGIN
    UPDATE Employees SET salary = salary + bonus_amount WHERE hire_date < CURDATE();
END //
DELIMITER ;

-- 34. Call the procedure
CALL GiveAnnualBonus(2000);

-- 35. Procedure to list all employees of a store
DELIMITER //
CREATE PROCEDURE GetEmployeesByStore(IN sid INT)
BEGIN
    SELECT * FROM Employees WHERE store_id = sid;
END //
DELIMITER ;

-- 36. Call procedure with store_id 3
CALL GetEmployeesByStore(3);

-- 37. UDF to get full name
DELIMITER //
CREATE FUNCTION get_full_name(fname VARCHAR(50), lname VARCHAR(50)) RETURNS VARCHAR(101)
DETERMINISTIC
BEGIN
    RETURN CONCAT(fname, ' ', lname);
END //
DELIMITER ;

-- 38. Use UDF in query
SELECT get_full_name(first_name, last_name) AS employee_name FROM Employees;

-- 39. Procedure to delete inactive employees
DELIMITER //
CREATE PROCEDURE RemoveInactiveEmployees()
BEGIN
    DELETE FROM Employees WHERE salary IS NULL OR salary <= 0;
END //
DELIMITER ;

-- 40. Execute
CALL RemoveInactiveEmployees();

-- 41. Employees per store with salary sum
SELECT store_id, COUNT(*) AS num_employees, SUM(salary) AS total_salaries
FROM Employees
GROUP BY store_id;

-- 42. Average age by position
SELECT position, AVG(TIMESTAMPDIFF(YEAR, birth_date, CURDATE())) AS avg_age
FROM Employees
GROUP BY position;

-- 43. Gender distribution
SELECT gender, COUNT(*) AS count FROM Employees GROUP BY gender;

-- 44. Salary rank within each store
SELECT employee_id, first_name, salary,
    RANK() OVER(PARTITION BY store_id ORDER BY salary DESC) AS rank_in_store
FROM Employees;

-- 45. Hiring trend by year
SELECT YEAR(hire_date) AS hire_year, COUNT(*) AS hired
FROM Employees
GROUP BY YEAR(hire_date);

-- 46. Count of birthdays by month
SELECT MONTH(birth_date) AS birth_month, COUNT(*) AS count
FROM Employees
GROUP BY MONTH(birth_date);

-- 47. Employees not involved in any sales
SELECT * FROM Employees
WHERE employee_id NOT IN (SELECT DISTINCT employee_id FROM Sales);

-- 48. Top 3 highest paid employees
SELECT * FROM Employees ORDER BY salary DESC LIMIT 3;

-- 49. Employees with the same first name
SELECT first_name, COUNT(*) FROM Employees GROUP BY first_name HAVING COUNT(*) > 1;

-- 50. Monthly salary expense
SELECT SUM(salary) AS total_monthly_salary FROM Employees;

-- tabele 3
-- create table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    join_date DATE,
    birth_date DATE,
    address VARCHAR(200)
    );

-- insert records

INSERT INTO Customers (customer_id, first_name, last_name, email, phone, join_date, birth_date, address) VALUES
(1, 'Amit', 'Sharma', 'amit.sharma@gmail.com', '9876543210', '2024-01-15', '1990-04-20', 'Bandra West, Mumbai'),
(2, 'Neha', 'Verma', 'neha.verma@gmail.com', '9876543211', '2023-12-10', '1995-09-12', 'Kothrud, Pune'),
(3, 'Raj', 'Malhotra', 'raj.malhotra@gmail.com', '9876543212', '2024-02-05', '1988-07-25', 'Banjara Hills, Hyderabad'),
(4, 'Priya', 'Iyer', 'priya.iyer@gmail.com', '9876543213', '2024-03-22', '1992-11-05', 'Indiranagar, Bangalore'),
(5, 'Vikram', 'Patel', 'vikram.patel@gmail.com', '9876543214', '2024-01-08', '1985-03-30', 'Satellite, Ahmedabad'),
(6, 'Sneha', 'Desai', 'sneha.desai@gmail.com', '9876543215', '2023-11-20', '1997-02-17', 'Thane West, Mumbai'),
(7, 'Ankit', 'Singh', 'ankit.singh@gmail.com', '9876543216', '2024-04-10', '1991-06-10', 'Gomti Nagar, Lucknow'),
(8, 'Ritika', 'Kapoor', 'ritika.kapoor@gmail.com', '9876543217', '2024-05-18', '1996-10-15', 'Salt Lake, Kolkata'),
(9, 'Kunal', 'Mehta', 'kunal.mehta@gmail.com', '9876543218', '2024-02-28', '1989-08-08', 'Alwarpet, Chennai'),
(10, 'Divya', 'Rao', 'divya.rao@gmail.com', '9876543219', '2024-03-01', '1993-12-03', 'Koramangala, Bangalore');

-- 1. Add new column to track loyalty points
ALTER TABLE Customers ADD loyalty_points INT DEFAULT 0;

-- 2. Modify address column to be NOT NULL
ALTER TABLE Customers MODIFY address VARCHAR(200) NOT NULL;

-- 3. Insert new customer record
INSERT INTO Customers VALUES 
(301, 'Priya', 'Mehta', 'priya.m@mall.com', '9988776655', '2023-06-15', '1990-03-12', 'Mumbai');

-- 4. Update phone number for specific customer
UPDATE Customers SET phone = '9876543210' WHERE customer_id = 301;

-- 5. Delete customers with NULL email
DELETE FROM Customers WHERE email IS NULL;

-- 6. Select all customers who joined this year
SELECT * FROM Customers WHERE YEAR(join_date) = YEAR(CURDATE());

-- 7. Begin a transaction to update points and commit
START TRANSACTION;
UPDATE Customers SET loyalty_points = loyalty_points + 50 WHERE customer_id = 301;
COMMIT;

-- 8. Rollback if points wrongly increased
START TRANSACTION;
UPDATE Customers SET loyalty_points = 100000;
ROLLBACK;

-- 9. Revoke DELETE access from junior staff
REVOKE DELETE ON Customers FROM junior_staff;

-- 10. Grant SELECT access to audit team
GRANT SELECT ON Customers TO audit_team;

-- 11. Customers from certain cities
SELECT * FROM Customers WHERE address IN ('Mumbai', 'Pune');

-- 12. CONCAT full name and alias it
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM Customers;

-- 13. Use of COALESCE to handle nulls in phone
SELECT first_name, COALESCE(phone, 'No phone') AS phone_number FROM Customers;

-- 14. UPPER and LIKE to search name patterns
SELECT * FROM Customers WHERE UPPER(first_name) LIKE 'P%';

-- 15. Customers who joined before age 25
SELECT *, TIMESTAMPDIFF(YEAR, birth_date, join_date) AS age_at_joining
FROM Customers
WHERE TIMESTAMPDIFF(YEAR, birth_date, join_date) < 25;

-- 16. Use of BETWEEN to filter join dates
SELECT * FROM Customers WHERE join_date BETWEEN '2024-01-01' AND '2024-12-31';

-- 17. Use of CASE to label loyalty
SELECT first_name, loyalty_points,
    CASE
        WHEN loyalty_points >= 500 THEN 'Gold'
        WHEN loyalty_points >= 200 THEN 'Silver'
        ELSE 'Bronze'
    END AS loyalty_level
FROM Customers;

-- 18. Alias columns for customer dashboard
SELECT customer_id AS ID, first_name AS Name, email AS Email FROM Customers;

-- 19. Use of INSTR to find address with 'road'
SELECT * FROM Customers WHERE INSTR(address, 'road') > 0;

-- 20. Use of ROUND and CEIL on loyalty stats
SELECT customer_id, ROUND(loyalty_points / 10.0, 1) AS points_per_10 FROM Customers;

-- 21. Join with Sales to get purchase history
SELECT c.first_name, s.sale_date, s.unit_price
FROM Customers c
JOIN Sales s ON c.customer_id = s.customer_id;

-- 22. Join with Products to get what customer bought
SELECT c.first_name, p.product_name, s.quantity
FROM Customers c
JOIN Sales s ON c.customer_id = s.customer_id
JOIN Products p ON s.product_id = p.product_id;

-- 23. Subquery to find customers who bought most items
SELECT * FROM Customers
WHERE customer_id IN (
    SELECT customer_id FROM Sales
    GROUP BY customer_id
    HAVING SUM(quantity) > 10
);

-- 24. View: Premium customers with high loyalty
CREATE VIEW PremiumCustomers AS
SELECT * FROM Customers WHERE loyalty_points >= 500;

-- 25. CTE: Recent customers (last 90 days)
WITH RecentCustomers AS (
    SELECT * FROM Customers WHERE join_date >= CURDATE() - INTERVAL 90 DAY
)
SELECT * FROM RecentCustomers;

-- 26. Correlated subquery: Customers who spent above average
SELECT * FROM Customers c
WHERE EXISTS (
    SELECT 1 FROM Sales s WHERE s.customer_id = c.customer_id
    GROUP BY s.customer_id
    HAVING SUM(s.unit_price * s.quantity) > 
           (SELECT AVG(unit_price * quantity) FROM Sales)
);

-- 27. Join with Employees (who handled their sale)
SELECT c.first_name AS Customer, e.first_name AS Employee
FROM Customers c
JOIN Sales s ON c.customer_id = s.customer_id
JOIN Employees e ON s.employee_id = e.employee_id;

-- 28. Use of NOT EXISTS to find inactive customers
SELECT * FROM Customers c
WHERE NOT EXISTS (
    SELECT 1 FROM Sales s WHERE s.customer_id = c.customer_id
);

-- 29. Top customer by total sales amount
SELECT customer_id, SUM(unit_price * quantity) AS total_spent
FROM Sales
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 1;

-- 30. Count of products each customer bought
SELECT c.customer_id, c.first_name, COUNT(DISTINCT s.product_id) AS products_bought
FROM Customers c
JOIN Sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id;

-- 31. Function to calculate age from birthdate
DELIMITER //
CREATE FUNCTION get_age(birthdate DATE) RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, birthdate, CURDATE());
END //
DELIMITER ;

-- 32. Using the UDF
SELECT customer_id, get_age(birth_date) AS age FROM Customers;

-- 33. Procedure to reset loyalty points
DELIMITER //
CREATE PROCEDURE ResetLoyalty()
BEGIN
    UPDATE Customers SET loyalty_points = 0 WHERE loyalty_points < 100;
END //
DELIMITER ;

-- 34. Call it
CALL ResetLoyalty();

-- 35. Procedure to insert new customer
DELIMITER //
CREATE PROCEDURE AddCustomer(
    IN cid INT,
    IN fname VARCHAR(50),
    IN lname VARCHAR(50),
    IN emailid VARCHAR(100),
    IN mobile VARCHAR(15),
    IN joindt DATE,
    IN birthdt DATE,
    IN addr VARCHAR(200)
)
BEGIN
    INSERT INTO Customers VALUES (cid, fname, lname, emailid, mobile, joindt, birthdt, addr);
END //
DELIMITER ;

-- 36. Call procedure
CALL AddCustomer(310, 'Vikas', 'Rana', 'vikas@mall.com', '9811111222', '2025-07-01', '1992-05-14', 'Navi Mumbai');

-- 37. Function to get full name
DELIMITER //
CREATE FUNCTION full_name(fname VARCHAR(50), lname VARCHAR(50)) RETURNS VARCHAR(101)
DETERMINISTIC
BEGIN
    RETURN CONCAT(fname, ' ', lname);
END //
DELIMITER ;

-- 38. Use of full name function
SELECT customer_id, full_name(first_name, last_name) AS name FROM Customers;

-- 39. Procedure to boost loyalty by city
DELIMITER //
CREATE PROCEDURE BoostLoyalty(IN city VARCHAR(100), IN points INT)
BEGIN
    UPDATE Customers SET loyalty_points = loyalty_points + points WHERE address LIKE CONCAT('%', city, '%');
END //
DELIMITER ;

-- 40. Call the loyalty booster
CALL BoostLoyalty('Mumbai', 50);

-- 41. Age group classification
SELECT customer_id, 
    CASE
        WHEN get_age(birth_date) < 18 THEN 'Teen'
        WHEN get_age(birth_date) < 30 THEN 'Young Adult'
        WHEN get_age(birth_date) < 50 THEN 'Adult'
        ELSE 'Senior'
    END AS age_group
FROM Customers;

-- 42. Total spend by each city
SELECT address AS city, SUM(s.unit_price * s.quantity) AS total_spend
FROM Customers c
JOIN Sales s ON c.customer_id = s.customer_id
GROUP BY address;

-- 43. First and last transaction date
SELECT c.customer_id, MIN(s.sale_date) AS first_sale, MAX(s.sale_date) AS last_sale
FROM Customers c
JOIN Sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id;

-- 44. Most loyal customers by sales + loyalty
SELECT c.customer_id, (SUM(s.unit_price * s.quantity) + c.loyalty_points) AS score
FROM Customers c
JOIN Sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id
ORDER BY score DESC;

-- 45. Yearly customer joining stats
SELECT YEAR(join_date) AS year, COUNT(*) AS total_joined
FROM Customers
GROUP BY YEAR(join_date);

-- 46. Customers with at least 5 purchases
SELECT customer_id, COUNT(*) AS num_purchases
FROM Sales
GROUP BY customer_id
HAVING COUNT(*) >= 5;

-- 47. Gender ratio (if gender column is added later)
-- (Assume gender CHAR(1) added)
SELECT gender, COUNT(*) AS total FROM Customers GROUP BY gender;

-- 48. Month-wise customer growth
SELECT MONTH(join_date) AS month, COUNT(*) AS new_customers
FROM Customers
WHERE YEAR(join_date) = YEAR(CURDATE())
GROUP BY MONTH(join_date);

-- 49. Customers born in same month as join
SELECT * FROM Customers WHERE MONTH(birth_date) = MONTH(join_date);

-- 50. Loyalty tier upgrade suggestion
SELECT customer_id, loyalty_points,
    CASE
        WHEN loyalty_points >= 1000 THEN 'Eligible for VIP'
        WHEN loyalty_points >= 500 THEN 'Upgrade to Gold'
        WHEN loyalty_points >= 200 THEN 'Upgrade to Silver'
        ELSE 'No upgrade'
    END AS suggestion
FROM Customers;

-- Table 4
-- create table 
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    category_name VARCHAR(50),
    price DECIMAL(10,2),
    stock INT,
    brand VARCHAR(100),
    supplier VARCHAR(100),
    created_at DATE 
);

-- insert records
INSERT INTO Products (
    product_id, product_name, category_id, category_name, price, stock, brand, supplier, created_at
) VALUES
(5001, 'Men''s Formal Shirt', 1, 'Clothing', 1299.00, 50, 'Peter England', 'Textile Corp', '2025-07-01'),
(5002, 'Women''s Kurti', 1, 'Clothing', 899.00, 75, 'FabIndia', 'Textile Corp', '2025-07-02'),
(5003, 'Smartphone X10', 2, 'Electronics', 25999.00, 30, 'TechBrand', 'Electro Distributors', '2025-06-28'),
(5004, 'Wireless Earbuds', 2, 'Electronics', 1999.00, 100, 'SoundPlus', 'Electro Distributors', '2025-06-25'),
(5005, 'Gourmet Chocolate Cake', 3, 'Food', 599.00, 20, 'Delicious Bites', 'Food Suppliers Inc', '2025-07-05'),
(5006, 'Bestseller Novel', 4, 'Books', 399.00, 60, 'Book House', 'Publishing Co', '2025-07-06'),
(5007, 'Ceramic Dinner Set', 5, 'Home Goods', 2499.00, 40, 'HomeStyle', 'Home Products Ltd', '2025-07-03'),
(5008, 'Yoga Mat', 6, 'Sports', 899.00, 80, 'FitLife', 'Sports Gear Inc', '2025-06-30'),
(5009, 'Luxury Perfume', 7, 'Cosmetics', 3499.00, 25, 'Glamour', 'Beauty Products', '2025-07-04'),
(5010, 'Educational Toy Set', 8, 'Toys', 1299.00, 65, 'FunLearn', 'Toy Manufacturers', '2025-07-07');

-- 1. Add column for expiry_date
ALTER TABLE Products ADD expiry_date DATE;

-- 2. Modify stock column to be NOT NULL with default
ALTER TABLE Products MODIFY stock INT NOT NULL DEFAULT 0;

-- 3. Insert new product
INSERT INTO Products VALUES 
(1001, 'Wireless Mouse', 1, 'Electronics', 799.00, 100, 'Logitech', 'TechSupplier Inc.', '2025-07-01');

-- 4. Update stock after new shipment
UPDATE Products SET stock = stock + 50 WHERE product_id = 1001;

-- 5. Delete products with NULL brand
DELETE FROM Products WHERE brand IS NULL;

-- 6. Select all products with price > 1000
SELECT * FROM Products WHERE price > 1000;

-- 7. Begin transaction: Update stock and commit
START TRANSACTION;
UPDATE Products SET stock = stock - 5 WHERE product_id = 1001;
COMMIT;

-- 8. Rollback faulty price update
START TRANSACTION;
UPDATE Products SET price = -100;
ROLLBACK;

-- 9. Grant INSERT and UPDATE to inventory_user
GRANT INSERT, UPDATE ON Products TO inventory_user;

-- 10. Revoke DELETE from general_user
REVOKE DELETE ON Products FROM general_user;

-- 11. Use BETWEEN to filter price range
SELECT * FROM Products WHERE price BETWEEN 500 AND 1500;

-- 12. Alias with calculated discount price (10% off)
SELECT product_name, price, price * 0.9 AS discounted_price FROM Products;

-- 13. Use of UPPER and LIKE to filter brand
SELECT * FROM Products WHERE UPPER(brand) LIKE 'SAMSUNG%';

-- 14. CONCAT brand and name
SELECT CONCAT(brand, ' - ', product_name) AS full_label FROM Products;

-- 15. Null-safe supplier check using COALESCE
SELECT product_id, COALESCE(supplier, 'No Supplier') AS Supplier FROM Products;

-- 16. Use of IN to get specific categories
SELECT * FROM Products WHERE category_name IN ('Electronics', 'Apparel');

-- 17. CASE for stock status
SELECT product_name, stock,
    CASE
        WHEN stock = 0 THEN 'Out of Stock'
        WHEN stock < 10 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM Products;

-- 18. ROUND price to nearest 10
SELECT product_name, ROUND(price, -1) AS rounded_price FROM Products;

-- 19. Use of LENGTH to find short product names
SELECT * FROM Products WHERE LENGTH(product_name) < 10;

-- 20. Use of FLOOR and CEIL for price adjustment
SELECT price, FLOOR(price) AS floor_price, CEIL(price) AS ceil_price FROM Products;

-- 21. Join with Sales to find top-selling products
SELECT p.product_name, COUNT(s.sale_id) AS total_sales
FROM Products p
JOIN Sales s ON p.product_id = s.product_id
GROUP BY p.product_id
ORDER BY total_sales DESC;

-- 22. Subquery to get products with price above average
SELECT * FROM Products
WHERE price > (SELECT AVG(price) FROM Products);

-- 23. CTE for low stock products
WITH LowStock AS (
    SELECT * FROM Products WHERE stock < 10
)
SELECT * FROM LowStock;

-- 24. Products never sold
SELECT * FROM Products
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM Sales);

-- 25. View for all Electronics items
CREATE VIEW ElectronicsItems AS
SELECT * FROM Products WHERE category_name = 'Electronics';

-- 26. Products sold by brand with revenue
SELECT p.brand, SUM(s.unit_price * s.quantity) AS revenue
FROM Products p
JOIN Sales s ON p.product_id = s.product_id
GROUP BY p.brand;

-- 27. Subquery with category-wise max price
SELECT * FROM Products p
WHERE price = (
    SELECT MAX(price) FROM Products WHERE category_name = p.category_name
);

-- 28. Join with Customers who bought this product
SELECT DISTINCT p.product_name, c.first_name
FROM Products p
JOIN Sales s ON p.product_id = s.product_id
JOIN Customers c ON s.customer_id = c.customer_id;

-- 29. Join with Employees who sold most units of each product
SELECT p.product_name, e.first_name, SUM(s.quantity) AS total_sold
FROM Products p
JOIN Sales s ON p.product_id = s.product_id
JOIN Employees e ON s.employee_id = e.employee_id
GROUP BY p.product_id, e.employee_id;

-- 30. Count of categories and average price
SELECT category_name, COUNT(*) AS num_products, AVG(price) AS avg_price
FROM Products
GROUP BY category_name;

-- 31. Function to apply tax (18%)
DELIMITER //
CREATE FUNCTION apply_tax(p DECIMAL(10,2)) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p * 1.18;
END //
DELIMITER ;

-- 32. Use function to get price with tax
SELECT product_name, apply_tax(price) AS price_with_tax FROM Products;

-- 33. Procedure to restock a product
DELIMITER //
CREATE PROCEDURE RestockProduct(IN pid INT, IN qty INT)
BEGIN
    UPDATE Products SET stock = stock + qty WHERE product_id = pid;
END //
DELIMITER ;

-- 34. Call the restocking procedure
CALL RestockProduct(1001, 20);

-- 35. Procedure to update product price by brand
DELIMITER //
CREATE PROCEDURE UpdatePriceByBrand(IN brand_name VARCHAR(50), IN percent DECIMAL(5,2))
BEGIN
    UPDATE Products 
    SET price = price * (1 + percent / 100)
    WHERE brand = brand_name;
END //
DELIMITER ;

-- 36. Call procedure to increase price by 10%
CALL UpdatePriceByBrand('Logitech', 10);

-- 37. Function to shorten product name
DELIMITER //
CREATE FUNCTION short_name(name VARCHAR(100)) RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    RETURN LEFT(name, 10);
END //
DELIMITER ;

-- 38. Use function
SELECT product_id, short_name(product_name) AS short FROM Products;

-- 39. Procedure to remove discontinued products
DELIMITER //
CREATE PROCEDURE RemoveDiscontinued()
BEGIN
    DELETE FROM Products WHERE stock = 0 AND created_at < CURDATE() - INTERVAL 1 YEAR;
END //
DELIMITER ;

-- 40. Execute procedure
CALL RemoveDiscontinued();

-- 41. Top 5 most expensive products per category
SELECT * FROM (
    SELECT *, RANK() OVER(PARTITION BY category_name ORDER BY price DESC) AS rnk
    FROM Products
) AS ranked
WHERE rnk <= 5;

-- 42. Monthly added products
SELECT MONTH(created_at) AS month, COUNT(*) AS new_products
FROM Products
GROUP BY MONTH(created_at);

-- 43. Products nearing expiry in next 30 days
SELECT * FROM Products
WHERE expiry_date IS NOT NULL AND expiry_date <= CURDATE() + INTERVAL 30 DAY;

-- 44. Category-wise stock levels
SELECT category_name, SUM(stock) AS total_stock
FROM Products
GROUP BY category_name;

-- 45. Products with highest revenue
SELECT p.product_id, p.product_name, SUM(s.unit_price * s.quantity) AS revenue
FROM Products p
JOIN Sales s ON p.product_id = s.product_id
GROUP BY p.product_id
ORDER BY revenue DESC;

-- 46. Products that haven’t been updated in over 6 months
SELECT * FROM Products
WHERE created_at < CURDATE() - INTERVAL 6 MONTH;

-- 47. Number of products per brand
SELECT brand, COUNT(*) AS num_products FROM Products GROUP BY brand;

-- 48. Product price trend (if price history available)
-- (Assuming a price_history table: product_id, price, change_date)

-- 49. Total inventory value per category
SELECT category_name, SUM(price * stock) AS inventory_value
FROM Products
GROUP BY category_name;

-- 50. Products with unusual pricing (price < 50 or > 50000)
SELECT * FROM Products
WHERE price < 50 OR price > 50000;

-- Table 5
-- create table 
CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    customer_id INT REFERENCES Customers(customer_id),
    product_id INT REFERENCES Products(product_id),
    employee_id INT REFERENCES Employees(employee_id),
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    quantity INT CHECK (quantity > 0),
    unit_price DECIMAL(10,2),
    discount DECIMAL(10,2) DEFAULT 0,
    payment_method VARCHAR(20) CHECK (payment_method IN ('Cash', 'Credit Card', 'Debit Card', 'Mobile Payment'))
);

-- insert records
INSERT INTO Sales VALUES 
(9001, 1001, 5001, 101, '2021-05-10 11:30:00', 2, 1299.00, 100.00, 'Credit Card'),
(9002, 1002, 5003, 103, '2021-05-12 14:45:00', 1, 25999.00, 1500.00, 'Debit Card'),
(9003, 1003, 5002, 102, '2021-05-15 16:20:00', 3, 899.00, 50.00, 'Cash'),
(9004, 1004, 5005, 105, '2021-05-18 12:15:00', 1, 599.00, 0.00, 'Mobile Payment'),
(9005, 1005, 5006, 106, '2021-05-20 18:30:00', 2, 399.00, 20.00, 'Debit Card'),
(9006, 1006, 5004, 104, '2021-05-22 15:10:00', 1, 1999.00, 100.00, 'Credit Card'),
(9007, 1007, 5008, 108, '2021-05-25 10:45:00', 1, 899.00, 0.00, 'Cash'),
(9008, 1008, 5007, 107, '2021-05-28 13:20:00', 1, 2499.00, 200.00, 'Credit Card'),
(9009, 1009, 5010, 110, '2021-06-01 17:00:00', 1, 1299.00, 50.00, 'Debit Card'),
(9010, 1010, 5009, 109, '2021-06-05 19:30:00', 1, 3499.00, 300.00, 'Credit Card');

-- 1. Add a column for tax_amount
ALTER TABLE Sales ADD tax_amount DECIMAL(10,2);

-- 2. Modify unit_price to ensure non-negative
ALTER TABLE Sales MODIFY unit_price DECIMAL(10,2) CHECK (unit_price >= 0);

-- 3. Insert a new sales transaction
INSERT INTO Sales VALUES 
(5001, 301, 1001, 201, NOW(), 2, 799.00, 0, 'Credit Card');

-- 4. Update payment method for a sale
UPDATE Sales SET payment_method = 'UPI' WHERE sale_id = 5001;

-- 5. Delete test records with price 0
DELETE FROM Sales WHERE unit_price = 0;

-- 6. Select all sales made via mobile payment
SELECT * FROM Sales WHERE payment_method = 'Mobile Payment';

-- 7. Begin transaction: Apply discount and commit
START TRANSACTION;
UPDATE Sales SET discount = 50 WHERE quantity > 5;
COMMIT;

-- 8. Rollback a faulty update
START TRANSACTION;
UPDATE Sales SET unit_price = -500;
ROLLBACK;

-- 9. Grant SELECT and INSERT on Sales
GRANT SELECT, INSERT ON Sales TO sales_entry;

-- 10. Revoke DELETE access
REVOKE DELETE ON Sales FROM junior_staff;

-- 11. Calculate total for each sale (with alias)
SELECT sale_id, quantity, unit_price, discount,
       (quantity * unit_price - discount) AS total_amount
FROM Sales;

-- 12. Use BETWEEN for date filtering
SELECT * FROM Sales WHERE sale_date BETWEEN '2025-07-01' AND '2025-07-10';

-- 13. Use CASE for payment method description
SELECT payment_method,
    CASE
        WHEN payment_method = 'Credit Card' THEN 'Card'
        WHEN payment_method = 'Mobile Payment' THEN 'Phone'
        ELSE 'Other'
    END AS method_type
FROM Sales;

-- 14. Round total price
SELECT sale_id, ROUND(quantity * unit_price, 2) AS total FROM Sales;

-- 15. Use COALESCE for default discount
SELECT sale_id, COALESCE(discount, 0) AS final_discount FROM Sales;

-- 16. Use IN to filter payment methods
SELECT * FROM Sales WHERE payment_method IN ('Cash', 'Debit Card');

-- 17. Use of UPPER to normalize method names
SELECT DISTINCT UPPER(payment_method) FROM Sales;

-- 18. Use MOD to group odd/even sale_ids
SELECT sale_id, MOD(sale_id, 2) AS is_even FROM Sales;

-- 19. Order by sale date descending
SELECT * FROM Sales ORDER BY sale_date DESC;

-- 20. LIMIT for recent 5 sales
SELECT * FROM Sales ORDER BY sale_date DESC LIMIT 5;

-- 21. Join Sales with Customers and Products
SELECT s.sale_id, c.first_name, p.product_name, s.quantity, s.unit_price
FROM Sales s
JOIN Customers c ON s.customer_id = c.customer_id
JOIN Products p ON s.product_id = p.product_id;

-- 22. Sales by employee names
SELECT s.sale_id, e.first_name AS employee, s.quantity
FROM Sales s
JOIN Employees e ON s.employee_id = e.employee_id;

-- 23. Subquery: Sales above average amount
SELECT * FROM Sales
WHERE (quantity * unit_price) > (
    SELECT AVG(quantity * unit_price) FROM Sales
);

-- 24. View: All high-value sales
CREATE VIEW HighValueSales AS
SELECT * FROM Sales WHERE (unit_price * quantity) > 5000;

-- 25. CTE: Daily sales summary
WITH DailySales AS (
    SELECT DATE(sale_date) AS sale_day, SUM(unit_price * quantity) AS total
    FROM Sales
    GROUP BY DATE(sale_date)
)
SELECT * FROM DailySales;

-- 26. Correlated subquery: Top sales per employee
SELECT * FROM Sales s
WHERE quantity = (
    SELECT MAX(quantity) FROM Sales WHERE employee_id = s.employee_id
);

-- 27. Join with Products to calculate brand-wise sale count
SELECT p.brand, COUNT(s.sale_id) AS brand_sales
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.brand;

-- 28. Subquery to find customers with most purchases
SELECT customer_id FROM Sales
GROUP BY customer_id
ORDER BY SUM(quantity) DESC LIMIT 1;

-- 29. Join to calculate customer spend
SELECT c.customer_id, c.first_name, SUM(s.unit_price * s.quantity - s.discount) AS total_spent
FROM Customers c
JOIN Sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id;

-- 30. Join Employees and Sales to count sales per staff
SELECT e.first_name, COUNT(s.sale_id) AS sales_count
FROM Employees e
JOIN Sales s ON e.employee_id = s.employee_id
GROUP BY e.employee_id;

-- 31. UDF to calculate final bill after discount
DELIMITER //
CREATE FUNCTION final_bill(q INT, price DECIMAL(10,2), d DECIMAL(10,2)) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN (q * price) - d;
END //
DELIMITER ;

-- 32. Use final_bill function
SELECT sale_id, final_bill(quantity, unit_price, discount) AS total_due FROM Sales;

-- 33. Procedure to apply bulk discount
DELIMITER //
CREATE PROCEDURE ApplyBulkDiscount()
BEGIN
    UPDATE Sales SET discount = 100 WHERE quantity >= 10;
END //
DELIMITER ;

-- 34. Execute procedure
CALL ApplyBulkDiscount();

-- 35. Procedure to add a new sale record
DELIMITER //
CREATE PROCEDURE AddSale(
    IN sid INT, IN cid INT, IN pid INT, IN eid INT, IN qty INT, IN price DECIMAL(10,2),
    IN dsc DECIMAL(10,2), IN pmethod VARCHAR(20)
)
BEGIN
    INSERT INTO Sales(sale_id, customer_id, product_id, employee_id, quantity, unit_price, discount, payment_method)
    VALUES (sid, cid, pid, eid, qty, price, dsc, pmethod);
END //
DELIMITER ;

-- 36. Call procedure
CALL AddSale(5020, 310, 1001, 202, 3, 699.00, 50, 'Cash');

-- 37. Procedure to remove test sales
DELIMITER //
CREATE PROCEDURE RemoveTestSales()
BEGIN
    DELETE FROM Sales WHERE sale_date < '2020-01-01';
END //
DELIMITER ;

-- 38. Call it
CALL RemoveTestSales();

-- 39. Function to check if sale is high-value
DELIMITER //
CREATE FUNCTION is_high_value(q INT, u DECIMAL(10,2)) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN q * u > 5000;
END //
DELIMITER ;

-- 40. Use is_high_value
SELECT sale_id, is_high_value(quantity, unit_price) AS big_sale FROM Sales;

-- 41. Monthly sales total
SELECT MONTH(sale_date) AS month, SUM(unit_price * quantity) AS total_revenue
FROM Sales
GROUP BY MONTH(sale_date);

-- 42. Best selling product
SELECT product_id, COUNT(*) AS sales_count
FROM Sales
GROUP BY product_id
ORDER BY sales_count DESC
LIMIT 1;

-- 43. Daily revenue
SELECT DATE(sale_date) AS date, SUM(quantity * unit_price) AS daily_total
FROM Sales
GROUP BY DATE(sale_date);

-- 44. Employee with highest revenue
SELECT employee_id, SUM(quantity * unit_price) AS total
FROM Sales
GROUP BY employee_id
ORDER BY total DESC
LIMIT 1;

-- 45. Average discount per payment method
SELECT payment_method, AVG(discount) AS avg_discount
FROM Sales
GROUP BY payment_method;

-- 46. Product sales trend
SELECT product_id, DATE(sale_date) AS date, SUM(quantity) AS units_sold
FROM Sales
GROUP BY product_id, DATE(sale_date)
ORDER BY product_id, date;

-- 47. Sales with zero discount
SELECT * FROM Sales WHERE discount = 0;

-- 48. Average unit price per product
SELECT product_id, AVG(unit_price) AS avg_price
FROM Sales
GROUP BY product_id;

-- 49. Number of sales by customer
SELECT customer_id, COUNT(*) AS total_sales
FROM Sales
GROUP BY customer_id;

-- 50. Sales with invalid quantity (if any)
SELECT * FROM Sales WHERE quantity <= 0;

