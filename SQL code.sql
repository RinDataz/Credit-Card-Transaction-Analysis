create schema credit_card_transaction;


-- create and fill tables from our CSV file

CREATE TABLE customers (
    CustomerID VARCHAR(255) PRIMARY KEY,
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    Email VARCHAR(255),
    Phone VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    Country VARCHAR(255),
    ZipCode VARCHAR(10)
);
-- make sure the file is under 'uploades in my sql server folder , u can find the correct directory using 
-- SHOW VARIABLES LIKE 'secure_file_priv'; 

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select*from credit_card_transaction.customers;

CREATE TABLE Transactions (
    TransactionID VARCHAR(255) PRIMARY KEY,
    CustomerID VARCHAR(255),
    TransactionDate DATETIME,
    TransactionAmount DECIMAL(10, 2),
    MerchantName VARCHAR(255),
    MerchantCategory VARCHAR(255),
    TransactionType VARCHAR(50),
    TransactionStatus VARCHAR(50),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select*from transactions

CREATE TABLE Merchants
  AS (SELECT MerchantName,MerchantCategory
      FROM transactions);

alter table merchants
ADD Merchants_ID INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST,
ADD PRIMARY KEY (Merchants_ID);

SELECT*from merchants;

-- Data Analysis
-- Monthly Transaction Summary:
SELECT 
    DATE_FORMAT(TransactionDate, '%Y-%m') AS Month,
    COUNT(*) AS TotalTransactions,
    SUM(TransactionAmount) AS TotalAmount,
    COUNT(DISTINCT CustomerID) AS UniqueCustomers
FROM Transactions
GROUP BY Month
ORDER BY Month;

-- Top Merchants by Transaction Amount:
SELECT 
    MerchantName,
    SUM(TransactionAmount) AS TotalSpent
FROM Transactions
GROUP BY MerchantName
ORDER BY TotalSpent DESC
LIMIT 10;

-- Fraudulent Transaction Detection:
SELECT 
    TransactionID,
    CustomerID,
    TransactionAmount,
    TransactionDate,
    MerchantName
FROM Transactions
WHERE TransactionStatus = 'Declined'
AND TransactionType = 'Purchase'
ORDER BY TransactionDate DESC;

-- Customer Spending Behavior:
SELECT 
    C.CustomerID,
    C.FirstName,
    C.LastName,
    SUM(T.TransactionAmount) AS TotalSpent,
    COUNT(T.TransactionID) AS TotalTransactions
FROM Customers C
JOIN Transactions T ON C.CustomerID = T.CustomerID
GROUP BY C.CustomerID, C.FirstName, C.LastName
ORDER BY TotalSpent DESC;

-- Monthly Growth in Transactions:
SELECT 
    DATE_FORMAT(TransactionDate, '%Y-%m') AS Month,
    COUNT(*) AS TotalTransactions,
    LAG(COUNT(*)) OVER (ORDER BY DATE_FORMAT(TransactionDate, '%Y-%m')) AS PreviousMonthTransactions,
    COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY DATE_FORMAT(TransactionDate, '%Y-%m')) AS TransactionGrowth
FROM Transactions
GROUP BY Month
ORDER BY Month;

-- Average Transaction Amount by Merchant Category:
SELECT 
    MerchantCategory,
    AVG(TransactionAmount) AS AvgTransactionAmount
FROM Transactions
GROUP BY MerchantCategory
ORDER BY AvgTransactionAmount DESC;

-- Transaction Distribution by Day of Week:
SELECT 
    DAYNAME(TransactionDate) AS DayOfWeek,
    COUNT(*) AS TotalTransactions
FROM Transactions
GROUP BY DayOfWeek
ORDER BY FIELD(DayOfWeek, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- Top Customers by Total Transactions:
SELECT 
    C.CustomerID,
    C.FirstName,
    C.LastName,
    COUNT(T.TransactionID) AS TotalTransactions
FROM Customers C
JOIN Transactions T ON C.CustomerID = T.CustomerID
GROUP BY C.CustomerID, C.FirstName, C.LastName
ORDER BY TotalTransactions DESC
LIMIT 10;

-- Transaction Volume During Peak Hours:
SELECT 
    HOUR(TransactionDate) AS HourOfDay,
    COUNT(*) AS TotalTransactions
FROM Transactions
GROUP BY HourOfDay
ORDER BY HourOfDay DESC;

-- Monthly Average Transactions per Customer:
SELECT 
    DATE_FORMAT(TransactionDate, '%Y-%m') AS Month,
    COUNT(*) / COUNT(DISTINCT CustomerID) AS AvgTransactionsPerCustomer
FROM Transactions
GROUP BY Month
ORDER BY Month;

