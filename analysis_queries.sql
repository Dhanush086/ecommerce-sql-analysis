
-- Query 1: Revenue per order (Top 10)
-- Business question: What are our highest-value orders?

SELECT 
    o.OrderID,
    c.CustomerName,
    SUM(o.Quantity * p.Price) AS OrderTotal
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON o.ProductID = p.ProductID
WHERE o.Status = 'Delivered'
GROUP BY o.OrderID, c.CustomerName
ORDER BY OrderTotal DESC
LIMIT 10;
------------------------------------------
-- Query 2: Revenue by category
-- Business question: Which product category generates the most revenue?

SELECT 
    p.Category,
    SUM(o.Quantity * p.Price) AS TotalRevenue,
    COUNT(DISTINCT o.OrderID) AS NumOrders
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
WHERE o.Status = 'Delivered'
GROUP BY p.Category
ORDER BY TotalRevenue DESC;

----------------------------------
-- Query 3: Top customers by spend
-- Business question: Who are our highest-value customers?

SELECT 
    c.CustomerName,
    SUM(o.Quantity * p.Price) AS TotalSpent,
    COUNT(DISTINCT o.OrderID) AS NumOrders
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON o.ProductID = p.ProductID
WHERE o.Status = 'Delivered'
GROUP BY c.CustomerName
ORDER BY TotalSpent DESC
LIMIT 5;

-------------------------------
-- Query 4: Best-selling product per category (Window Function + CTE)
-- Business question: What's the best-selling product in each category?

WITH ProductRevenue AS (
    SELECT 
        p.Category,
        p.ProductName,
        SUM(o.Quantity * p.Price) AS Revenue
    FROM Orders o
    JOIN Products p ON o.ProductID = p.ProductID
    WHERE o.Status = 'Delivered'
    GROUP BY p.Category, p.ProductName
),
RankedProducts AS (
    SELECT 
        Category,
        ProductName,
        Revenue,
        DENSE_RANK() OVER (PARTITION BY Category ORDER BY Revenue DESC) AS CategoryRank
    FROM ProductRevenue
)
SELECT Category, ProductName, Revenue
FROM RankedProducts
WHERE CategoryRank = 1
ORDER BY Category;

------------------------------------
-- Query 5: Monthly revenue trend with running total
-- Business question: How is revenue trending month over month?

SELECT 
    DATE_TRUNC('month', o.OrderDate)::DATE AS Month,
    SUM(o.Quantity * p.Price) AS MonthlyRevenue,
    SUM(SUM(o.Quantity * p.Price)) OVER (ORDER BY DATE_TRUNC('month', o.OrderDate)) AS RunningTotal
FROM Orders o
JOIN Products p ON o.ProductID = p.ProductID
WHERE o.Status = 'Delivered'
GROUP BY DATE_TRUNC('month', o.OrderDate)
ORDER BY Month;

-----------------------------------------
-- Query 6: Customers who spent above average
-- Business question: Which customers are above-average spenders?

SELECT 
    c.CustomerName,
    SUM(o.Quantity * p.Price) AS TotalSpent
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON o.ProductID = p.ProductID
WHERE o.Status = 'Delivered'
GROUP BY c.CustomerName
HAVING SUM(o.Quantity * p.Price) > (
    SELECT AVG(CustomerTotal) FROM (
        SELECT SUM(o2.Quantity * p2.Price) AS CustomerTotal
        FROM Orders o2
        JOIN Products p2 ON o2.ProductID = p2.ProductID
        WHERE o2.Status = 'Delivered'
        GROUP BY o2.CustomerID
    ) sub
)
ORDER BY TotalSpent DESC;

-------------------------------------
-- Query 7: Customers with no orders
-- Business question: Which customers have never placed an order?

SELECT c.CustomerID, c.CustomerName, c.SignupDate
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;

--------------------------------------
-- Query 8: Products never ordered
-- Business question: Which products have zero sales?

SELECT p.ProductID, p.ProductName, p.Category
FROM Products p
LEFT JOIN Orders o ON p.ProductID = o.ProductID
WHERE o.OrderID IS NULL;


-- Query 9: Order status breakdown
-- Business question: What percentage of orders are cancelled or returned?

SELECT 
    Status,
    COUNT(DISTINCT OrderID) AS NumOrders,
    ROUND(100.0 * COUNT(DISTINCT OrderID) / SUM(COUNT(DISTINCT OrderID)) OVER (), 2) AS PctOfOrders
FROM Orders
GROUP BY Status
ORDER BY NumOrders DESC;
