/*
===============================================================================
Retail Sales Analysis | SQL Portfolio Project
Author: Yousuf Khan
Platform: Microsoft SQL Server (SSMS)

Skills demonstrated:
- INNER JOIN and LEFT JOIN
- SUM, COUNT and AVG
- GROUP BY and HAVING
- CASE WHEN and conditional aggregation
- Date analysis with YEAR and MONTH
- CTEs
- DENSE_RANK and ROW_NUMBER window functions
===============================================================================
*/

USE Retail_Sales_Project;
GO

/* ---------------------------------------------------------------------------
   Q1. Show detailed order information using Orders, Customers and Products.
--------------------------------------------------------------------------- */
SELECT
    o.Order_ID,
    o.Order_Date,
    c.Customer_Name,
    c.Region,
    p.Product_Name,
    p.Category,
    o.Quantity,
    o.Sales_Amount,
    o.Status
FROM Orders AS o
INNER JOIN Customers AS c
    ON o.Customer_ID = c.Customer_ID
INNER JOIN Products AS p
    ON o.Product_ID = p.Product_ID;


/* ---------------------------------------------------------------------------
   Q2. Calculate Total Sales, Total Orders and Average Order Value
       for Completed orders.
--------------------------------------------------------------------------- */
SELECT
    SUM(o.Sales_Amount) AS Total_Sales,
    COUNT(o.Order_ID) AS Total_Orders,
    AVG(o.Sales_Amount) AS Average_Order_Value
FROM Orders AS o
WHERE o.Status = 'Completed';


/* ---------------------------------------------------------------------------
   Q3. Show Total Completed Sales by Region, highest to lowest.
--------------------------------------------------------------------------- */
SELECT
    c.Region,
    SUM(o.Sales_Amount) AS Total_Sales
FROM Orders AS o
INNER JOIN Customers AS c
    ON o.Customer_ID = c.Customer_ID
WHERE o.Status = 'Completed'
GROUP BY c.Region
ORDER BY Total_Sales DESC;


/* ---------------------------------------------------------------------------
   Q4. Show Total Completed Sales by Product Category.
--------------------------------------------------------------------------- */
SELECT
    p.Category,
    SUM(o.Sales_Amount) AS Total_Sales
FROM Orders AS o
INNER JOIN Products AS p
    ON o.Product_ID = p.Product_ID
WHERE o.Status = 'Completed'
GROUP BY p.Category
ORDER BY Total_Sales DESC;


/* ---------------------------------------------------------------------------
   Q5. Find the Top 5 Products by Completed Sales.
--------------------------------------------------------------------------- */
SELECT TOP 5
    p.Product_Name,
    SUM(o.Sales_Amount) AS Total_Sales
FROM Orders AS o
INNER JOIN Products AS p
    ON o.Product_ID = p.Product_ID
WHERE o.Status = 'Completed'
GROUP BY p.Product_Name
ORDER BY Total_Sales DESC;


/* ---------------------------------------------------------------------------
   Q6. Find the Top 5 Customers by Completed Sales.
--------------------------------------------------------------------------- */
SELECT TOP 5
    c.Customer_Name,
    SUM(o.Sales_Amount) AS Total_Sales
FROM Orders AS o
INNER JOIN Customers AS c
    ON o.Customer_ID = c.Customer_ID
WHERE o.Status = 'Completed'
GROUP BY c.Customer_Name
ORDER BY Total_Sales DESC;


/* ---------------------------------------------------------------------------
   Q7. Show the number of orders by Status.
--------------------------------------------------------------------------- */
SELECT
    o.Status,
    COUNT(o.Order_ID) AS Total_Orders
FROM Orders AS o
GROUP BY o.Status
ORDER BY Total_Orders DESC;


/* ---------------------------------------------------------------------------
   Q8. Show each Region's Completed, Pending and Cancelled order counts.
       Demonstrates CASE WHEN with conditional aggregation.
--------------------------------------------------------------------------- */
SELECT
    c.Region,
    SUM(CASE WHEN o.Status = 'Completed' THEN 1 ELSE 0 END) AS Completed_Orders,
    SUM(CASE WHEN o.Status = 'Pending' THEN 1 ELSE 0 END) AS Pending_Orders,
    SUM(CASE WHEN o.Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled_Orders
FROM Orders AS o
INNER JOIN Customers AS c
    ON o.Customer_ID = c.Customer_ID
GROUP BY c.Region
ORDER BY c.Region;


/* ---------------------------------------------------------------------------
   Q9. Find customers with no orders.
--------------------------------------------------------------------------- */
SELECT
    c.Customer_ID,
    c.Customer_Name
FROM Customers AS c
LEFT JOIN Orders AS o
    ON c.Customer_ID = o.Customer_ID
WHERE o.Order_ID IS NULL;


/* ---------------------------------------------------------------------------
   Q10. Find products with no orders.
--------------------------------------------------------------------------- */
SELECT
    p.Product_ID,
    p.Product_Name
FROM Products AS p
LEFT JOIN Orders AS o
    ON p.Product_ID = o.Product_ID
WHERE o.Order_ID IS NULL;


/* ---------------------------------------------------------------------------
   Q11. Classify orders by Sales Amount.
--------------------------------------------------------------------------- */
SELECT
    o.Order_ID,
    o.Sales_Amount,
    CASE
        WHEN o.Sales_Amount >= 100000 THEN 'High Value'
        WHEN o.Sales_Amount >= 50000 THEN 'Medium Value'
        ELSE 'Regular Value'
    END AS Sales_Category
FROM Orders AS o;


/* ---------------------------------------------------------------------------
   Q12. Show Regions whose Completed Sales are greater than 500,000.
--------------------------------------------------------------------------- */
SELECT
    c.Region,
    SUM(o.Sales_Amount) AS Total_Sales
FROM Orders AS o
INNER JOIN Customers AS c
    ON o.Customer_ID = c.Customer_ID
WHERE o.Status = 'Completed'
GROUP BY c.Region
HAVING SUM(o.Sales_Amount) > 500000
ORDER BY Total_Sales DESC;


/* ---------------------------------------------------------------------------
   Q13. Show each customer with Number of Orders and Total Sales.
        Keep only customers with at least 3 orders.
--------------------------------------------------------------------------- */
SELECT
    c.Customer_Name,
    COUNT(o.Order_ID) AS Number_of_Orders,
    SUM(o.Sales_Amount) AS Total_Sales
FROM Orders AS o
INNER JOIN Customers AS c
    ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Name
HAVING COUNT(o.Order_ID) >= 3
ORDER BY Total_Sales DESC;


/* ---------------------------------------------------------------------------
   Q14. Show Monthly Completed Sales chronologically.
--------------------------------------------------------------------------- */
SELECT
    YEAR(o.Order_Date) AS Sales_Year,
    MONTH(o.Order_Date) AS Sales_Month,
    SUM(o.Sales_Amount) AS Total_Sales
FROM Orders AS o
WHERE o.Status = 'Completed'
GROUP BY
    YEAR(o.Order_Date),
    MONTH(o.Order_Date)
ORDER BY
    Sales_Year,
    Sales_Month;


/* ---------------------------------------------------------------------------
   Q15. Show Average Completed Sales Amount by Region, highest to lowest.
--------------------------------------------------------------------------- */
SELECT
    c.Region,
    AVG(o.Sales_Amount) AS Average_Sales
FROM Orders AS o
INNER JOIN Customers AS c
    ON o.Customer_ID = c.Customer_ID
WHERE o.Status = 'Completed'
GROUP BY c.Region
ORDER BY Average_Sales DESC;


/*
===============================================================================
ADVANCED SQL BONUS QUERIES
These queries demonstrate CTEs and window functions.
===============================================================================
*/

/* ---------------------------------------------------------------------------
   Bonus 1. Use a CTE to find customers whose Total Completed Sales are
            above the average customer Completed Sales.
--------------------------------------------------------------------------- */
WITH CustomerSales AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        SUM(o.Sales_Amount) AS Total_Sales
    FROM Customers AS c
    INNER JOIN Orders AS o
        ON c.Customer_ID = o.Customer_ID
    WHERE o.Status = 'Completed'
    GROUP BY
        c.Customer_ID,
        c.Customer_Name
)
SELECT
    Customer_ID,
    Customer_Name,
    Total_Sales
FROM CustomerSales
WHERE Total_Sales >
(
    SELECT AVG(Total_Sales)
    FROM CustomerSales
)
ORDER BY Total_Sales DESC;


/* ---------------------------------------------------------------------------
   Bonus 2. Rank Products by Completed Sales using DENSE_RANK.
--------------------------------------------------------------------------- */
WITH ProductSales AS
(
    SELECT
        p.Product_ID,
        p.Product_Name,
        SUM(o.Sales_Amount) AS Total_Sales
    FROM Products AS p
    INNER JOIN Orders AS o
        ON p.Product_ID = o.Product_ID
    WHERE o.Status = 'Completed'
    GROUP BY
        p.Product_ID,
        p.Product_Name
)
SELECT
    Product_ID,
    Product_Name,
    Total_Sales,
    DENSE_RANK() OVER (
        ORDER BY Total_Sales DESC
    ) AS Sales_Rank
FROM ProductSales
ORDER BY Sales_Rank;


/* ---------------------------------------------------------------------------
   Bonus 3. Find each customer's highest-value order using ROW_NUMBER.
--------------------------------------------------------------------------- */
WITH RankedOrders AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        o.Order_ID,
        o.Sales_Amount,
        ROW_NUMBER() OVER (
            PARTITION BY c.Customer_ID
            ORDER BY o.Sales_Amount DESC
        ) AS Row_Num
    FROM Customers AS c
    INNER JOIN Orders AS o
        ON c.Customer_ID = o.Customer_ID
)
SELECT
    Customer_ID,
    Customer_Name,
    Order_ID,
    Sales_Amount
FROM RankedOrders
WHERE Row_Num = 1
ORDER BY Customer_ID;
