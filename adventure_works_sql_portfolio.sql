-- ===========================================================
-- LEVEL 1: Basic Queries & Aggregations
-- ===========================================================

-- Question 1: Retrieve top 5 products with highest ListPrice (> 0)
select top 5 
    ProductID,
    Name, 
    ListPrice
from Production.Product
where ListPrice <> 0
order by ListPrice desc;

-- Question 2: Find active products with high safety stock
SELECT 
    ProductID,
    Name,
    SafetyStockLevel,
    ListPrice
FROM Production.Product
WHERE ListPrice > 0
  AND SafetyStockLevel >= 500;

-- Question 3: Total sales revenue and total orders count per year
select	
    year(OrderDate) as SalesYear,
    count(SalesOrderID) as TotalOrders,
    sum(TotalDue) as TotalRevenue
from Sales.SalesOrderHeader
group by year(OrderDate)
order by TotalOrders;

-- Level 1 Final Project: Yearly sales summary for online orders with revenue over 1,000,000
select
    YEAR(OrderDate) AS SalesYear,
    count(SalesOrderID) as TotalOrders,
    sum(TotalDue) as TotalRevenue
from Sales.SalesOrderHeader
where OnlineOrderFlag = 1
group by year(OrderDate)
HAVING sum(TotalDue) > 1000000
order by TotalRevenue desc;


-- ===========================================================
-- LEVEL 2: Joins & Multi-Table Analysis
-- ===========================================================

-- Question 1: Sales revenue and order counts per product category
select 
    pc.Name AS CategoryName,
    SUM(sod.LineTotal) AS TotalRevenue,
    SUM(sod.OrderQty) AS TotalUnitsSold
from Sales.SalesOrderDetail sod
join Production.Product p
    on sod.ProductID = p.ProductID
join Production.ProductSubcategory psc 
    on psc.ProductSubcategoryID = p.ProductSubcategoryID
join Production.ProductCategory pc
    on pc.ProductCategoryID = psc.ProductCategoryID
group by pc.Name
order by TotalRevenue desc;

-- Question 2: Top 10 customers by total spend with customer names
select top 10
    p.FirstName + ' ' + p.LastName AS CustomerName,
    SUM(soh.TotalDue) AS TotalSpent
from Sales.SalesOrderHeader soh
join Sales.Customer c
    on soh.CustomerID = c.CustomerID
join Person.Person p
    on c.PersonID = p.BusinessEntityID
group by p.FirstName, p.LastName
order by TotalSpent desc;

-- Question 3: Customers who have never placed an order
select 
    c.CustomerID,
    c.AccountNumber
from Sales.Customer c
left join Sales.SalesOrderHeader soh
    on soh.CustomerID = c.CustomerID
where soh.SalesOrderID is null;


-- ===========================================================
-- LEVEL 3: Subqueries & CTEs
-- ===========================================================

-- Question 1: Filter products with a ListPrice higher than the overall average price
select 
    Name,
    ListPrice
from Production.Product
where ListPrice > (
    select AVG(ListPrice)
    from Production.Product
)
order by ListPrice desc;

-- Question 2: Top 5 customers by total purchase amount using CTE
with CustomerSales as (
    select 
        CustomerID,
        sum(TotalDue) as TotalSales
    from Sales.SalesOrderHeader
    group by CustomerID
)
select top 5 
    CustomerID,
    TotalSales
from CustomerSales
order by TotalSales desc;

-- Question 3: Identify products with zero sales history
select 
    ProductID,
    Name,
    ProductNumber
from Production.Product 
where ProductID not in (
    select distinct ProductID
    from Sales.SalesOrderDetail
    where ProductID IS NOT NULL
)
order by ProductID;

-- Question 4: Products priced higher than their subcategory average
with avgpricecte as (
    select 
        avg(listprice) as overallavg
    from production.product
    where listprice > 0
)
select 
    p.productid,
    p.name,
    p.listprice,
    a.overallavg
from production.product p
cross join avgpricecte a
where p.listprice > a.overallavg
order by p.listprice desc;


-- ===========================================================
-- LEVEL 4: Advanced Window Functions
-- ===========================================================

-- Question 1: Rank Sales Territories by Total Revenue
select 
    TerritoryID,
    sum(TotalDue) as total,
    DENSE_RANK() OVER (ORDER BY SUM(TotalDue) DESC) AS Revenue_Rank
from Sales.SalesOrderHeader
group by TerritoryID
order by TerritoryID asc;

-- Question 2: Compare Current Order Amount to First Order 
select 
    CustomerID,
    OrderDate,
    TotalDue,
    first_value(TotalDue) over(partition by CustomerID ORDER BY OrderDate) as FirstOrderAmount
from Sales.SalesOrderHeader;

-- Question 3: Calculate Monthly Sales Difference using LAG
WITH MonthlySales AS (
    SELECT 
        year(OrderDate) AS SalesYear,
        month(OrderDate) AS SalesMonth,
        sum(TotalDue) AS CurrentMonthSales
    FROM Sales.SalesOrderHeader
    GROUP BY 
        year(OrderDate),
        month(OrderDate)
)
SELECT 
    SalesYear,
    SalesMonth,
    CurrentMonthSales,
    lag(CurrentMonthSales) over(order by SalesYear, SalesMonth) AS PreviousMonthSales,
    CurrentMonthSales - lag(CurrentMonthSales) over(order by SalesYear, SalesMonth) AS MonthlyDifference
FROM MonthlySales
ORDER BY SalesYear, SalesMonth;

-- Question 4: Top 3 Best Selling Products per Product Category
with RankedProducts as (
    select 
        c.Name as CategoryName,
        p.Name as ProductName,
        sum(d.LineTotal) as TotalSales,
        row_number() over(partition by c.Name order by sum(d.LineTotal) desc) as rn
    from Sales.SalesOrderDetail d
    join Sales.SalesOrderHeader h on d.SalesOrderID = h.SalesOrderID
    join Production.Product p on d.ProductID = p.ProductID
    join Production.ProductSubcategory s on p.ProductSubcategoryID = s.ProductSubcategoryID
    join Production.ProductCategory c on s.ProductCategoryID = c.ProductCategoryID
    group by 
        c.Name,
        p.Name
)
select 
    CategoryName,
    ProductName,
    TotalSales,
    rn
from RankedProducts
where rn <= 3
order by CategoryName, rn;

-- Question 5: Calculate 3-Month Moving Average of Total Sales
with MonthlySales as (
    select 
        year(OrderDate) as SalesYear,
        month(OrderDate) as SalesMonth,
        sum(TotalDue) as CurrentMonthSales
    from Sales.SalesOrderHeader
    group by 
        year(OrderDate),
        month(OrderDate)
)
select 
    SalesYear,
    SalesMonth,
    CurrentMonthSales,
    avg(CurrentMonthSales) over(
        order by SalesYear, SalesMonth 
        rows between 2 preceding and current row
    ) as MovingAvg3Months
from MonthlySales
order by SalesYear, SalesMonth;


-- ===========================================================
-- LEVEL 5: Correlated Subqueries & Anti-Semi Joins
-- ===========================================================

-- Question 1: Products Priced Above Subcategory Average
select 
    ProductID,
    Name,
    ListPrice,
    ProductSubcategoryID
from Production.Product as p
where ListPrice > (
    select avg(ListPrice)
    from Production.Product as a
    where p.ProductSubcategoryID = a.ProductSubcategoryID
);

-- Question 2: Customers Spending Above Regional Average
select 
    CustomerID,
    TerritoryID,
    sum(TotalDue) as TotalSales
from Sales.SalesOrderHeader as main
group by 
    CustomerID,
    TerritoryID
having sum(TotalDue) > (
    select avg(CustomerTotal)
    from (
        select 
            CustomerID,
            TerritoryID,
            sum(TotalDue) as CustomerTotal
        from Sales.SalesOrderHeader
        group by 
            CustomerID,
            TerritoryID
    ) as sub
    where sub.TerritoryID = main.TerritoryID
);

-- Question 3: Products Never Ordered (Anti-Semi Join)
select 
    ProductID,
    Name,
    ListPrice
from Production.Product as p
where not exists (
    select 1
    from Sales.SalesOrderDetail as sod
    where sod.ProductID = p.ProductID
);

-- Question 4: Customers with No Orders in a Specific Year
select 
    CustomerID,
    AccountNumber
from Sales.Customer as c
where not exists (
    select 1
    from Sales.SalesOrderHeader as soh
    where soh.CustomerID = c.CustomerID
      and year(soh.OrderDate) = 2013
);

-- Question 5: Employees Earning Above Department Average
select 
    e.BusinessEntityID,
    e.JobTitle,
    p.Rate
from HumanResources.EmployeePayHistory as p
join HumanResources.EmployeeDepartmentHistory as d 
    on p.BusinessEntityID = d.BusinessEntityID
join HumanResources.Employee as e 
    on e.BusinessEntityID = p.BusinessEntityID
where p.Rate > (
    select avg(p_sub.Rate)
    from HumanResources.EmployeePayHistory as p_sub
    join HumanResources.EmployeeDepartmentHistory as d_sub 
        on p_sub.BusinessEntityID = d_sub.BusinessEntityID
    where d_sub.DepartmentID = d.DepartmentID
      and d_sub.EndDate is null
)
  and d.EndDate is null;

-- Question 6: Categories with More Than 5 Products (Correlated Exists)
select 
    pc.ProductCategoryID,
    pc.Name as CategoryName
from Production.ProductCategory as pc
where exists (
    select 1
    from Production.ProductSubcategory as psc
    join Production.Product as p 
        on psc.ProductSubcategoryID = p.ProductSubcategoryID
    where psc.ProductCategoryID = pc.ProductCategoryID
    group by psc.ProductSubcategoryID
    having count(p.ProductID) > 5
);
