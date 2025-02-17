/*
====================================================
FRAUD DETECTION ANALYSIS SQL QUERY
====================================================
Author:        Austin Kean
Date Created:  02/01/2025
Description:   This SQL script detects high-risk transactions
               by analyzing order history, price inconsistencies, 
               duplicate orders, and customer risk levels.
====================================================
*/

-- ====================================================
-- STEP 1: Aggregate Order Data for Analysis
-- ====================================================
WITH OrderSummary AS (
    SELECT 
        o.OrderID, 
        o.CustomerID, 
        c.CompanyName,
        SUM(od.Quantity * od.UnitPrice) AS OrderTotal,  
        SUM(od.Quantity) AS TotalQuantity,  
        AVG(od.UnitPrice) AS AvgProductPrice,  
        COUNT(o.OrderID) OVER (PARTITION BY o.CustomerID ORDER BY o.OrderDate ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) AS RecentOrderCount, 
        MAX(od.UnitPrice) - MIN(od.UnitPrice) AS PriceVariation, 
        o.OrderDate,
        c.Country AS CustomerCountry
    FROM Orders o
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    JOIN Customers c ON o.CustomerID = c.CustomerID
    GROUP BY o.OrderID, o.CustomerID, c.CompanyName, o.OrderDate, c.Country
),

-- ====================================================
-- STEP 2: Identify High-Risk Orders (OrderTotal > $5000)
-- ====================================================
HighRiskOrders AS (
    SELECT 
        OrderID, 
        CustomerID, 
        OrderTotal, 
        TotalQuantity,
        RecentOrderCount,
        PriceVariation,
        CASE
			WHEN OrderTotal > 10000 THEN 3
            WHEN OrderTotal > 5000 THEN 2  
            WHEN OrderTotal > (SELECT AVG(OrderTotal) * 2 FROM OrderSummary) THEN 2
            WHEN TotalQuantity > (SELECT AVG(TotalQuantity) * 3 FROM OrderSummary) THEN 2  
            WHEN RecentOrderCount > 7 THEN 2  
            WHEN PriceVariation > (SELECT AVG(PriceVariation) * 3 FROM OrderSummary) THEN 2  
            WHEN CustomerCountry IN ('Nigeria', 'Russia', 'Vietnam', 'Brazil') THEN 1  
            ELSE 0 
        END AS HighRiskFlag 
    FROM OrderSummary
),

-- ====================================================
-- STEP 3: Detect Duplicate Orders by Customers
-- ====================================================
DuplicateOrders AS (
    SELECT 
        CustomerID, 
        COUNT(OrderID) AS DuplicateOrderCount, 
        MIN(OrderDate) AS FirstOrderDate, 
        MAX(OrderDate) AS LastOrderDate
    FROM Orders
    GROUP BY CustomerID
    HAVING COUNT(OrderID) > 1
),

-- ====================================================
-- STEP 4: Detect Price Manipulation in Orders
-- ====================================================
PriceInconsistency AS (
    SELECT 
        od.OrderID, 
        COUNT(DISTINCT od.UnitPrice) AS PriceVariations, 
        MIN(od.UnitPrice) AS MinPrice,
        MAX(od.UnitPrice) AS MaxPrice
    FROM [Order Details] od
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY od.OrderID
    HAVING COUNT(DISTINCT od.UnitPrice) > 1
),

-- ====================================================
-- STEP 5: Classify Customers by Risk Level
-- ====================================================
CustomerRisk AS (
    SELECT 
        o.CustomerID, 
        c.CompanyName,
        c.Country AS CustomerCountry,
        COUNT(o.OrderID) AS TotalOrders,
        SUM(od.Quantity * od.UnitPrice) AS TotalSpent,
        AVG(od.Quantity) AS AvgQuantityPerOrder,
        CASE 
            WHEN SUM(od.Quantity * od.UnitPrice) > 10000 THEN 'High Risk' 
            WHEN COUNT(o.OrderID) > (SELECT AVG(TotalOrders) FROM 
                                     (SELECT COUNT(OrderID) AS TotalOrders FROM Orders 
                                      GROUP BY CustomerID) AS subquery) THEN 'Medium Risk' 
            ELSE 'Low Risk'
        END AS CustomerRiskLevel
    FROM Orders o
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    JOIN Customers c ON o.CustomerID = c.CustomerID
    GROUP BY o.CustomerID, c.CompanyName, c.Country
)

-- ====================================================
-- FINAL QUERY: Merge All Results into a Fraud Detection Report
-- ====================================================
SELECT 
    os.*, 
    hr.HighRiskFlag, 
    COALESCE(d.DuplicateOrderCount, 0) AS DuplicateOrderCount,
    COALESCE(d.FirstOrderDate, os.OrderDate) AS FirstOrderDate, 
    COALESCE(d.LastOrderDate, os.OrderDate) AS LastOrderDate,
    cr.CustomerRiskLevel, 
    COALESCE(pi.PriceVariations, 0) AS PriceVariations, 
    COALESCE(pi.MinPrice, os.AvgProductPrice) AS MinPrice, 
    COALESCE(pi.MaxPrice, os.AvgProductPrice) AS MaxPrice
FROM OrderSummary os
LEFT JOIN HighRiskOrders hr ON os.OrderID = hr.OrderID
LEFT JOIN DuplicateOrders d ON os.CustomerID = d.CustomerID
LEFT JOIN CustomerRisk cr ON os.CustomerID = cr.CustomerID
LEFT JOIN PriceInconsistency pi ON os.OrderID = pi.OrderID
ORDER BY os.OrderTotal DESC;
