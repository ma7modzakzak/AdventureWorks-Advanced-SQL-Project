# Advanced SQL Data Analysis Portfolio - AdventureWorks

## 📌 Project Overview
This repository showcases an end-to-end SQL data analysis portfolio utilizing the globally recognized **AdventureWorks** relational sample database in MS SQL Server. 

The primary objective of this project is to bridge the gap between raw data and business decision-making by translating complex, real-world business scenarios into clean, optimized, and advanced SQL queries. The project progresses systematically through **5 distinct mastery levels**—starting from basic aggregations up to advanced Window Functions, Correlated Subqueries, and Anti-Semi Joins.

---

## 🛠️ Technical Skills & Concepts Demonstrated
- **Data Filtering & Aggregations:** `GROUP BY`, `HAVING`, sorting, and multi-condition filtering (`AND`/`OR`).
- **Multi-Table Joins:** Inner joins, left joins across complex relational schemas (Customers, Sales, Products, and Human Resources).
- **Subqueries & Advanced Logic:** Correlated Subqueries, Anti-Semi Joins (`NOT EXISTS`, `NOT IN`), and multi-level nesting.
- **Common Table Expressions (CTEs):** Modularizing queries for improved performance, readability, and maintainability.
- **Advanced Window Functions:** Ranking functions (`ROW_NUMBER`, `DENSE_RANK`), value navigation (`FIRST_VALUE`, `LAG`), and running calculations / moving averages (`ROWS BETWEEN`).

---

## 📂 Business Scenarios & Key Analyses Breakdown

### 🚀 Level 1: Basic Queries & Aggregations
* **Objective:** Extract core product listings, apply safety stock thresholds, and calculate yearly sales performance.
* **Key Insights:** Filtered high-value products, identified inventory requirements, and summarized total revenue and order counts for online sales over \$1M using `HAVING`.

### 🔗 Level 2: Joins & Multi-Table Analysis
* **Objective:** Connect customers, sales details, and product hierarchies to uncover revenue drivers.
* **Key Insights:** Evaluated total revenue per product category, isolated top 10 customers by total spend, and identified inactive customers who have never placed an order using a `LEFT JOIN`.

### 💡 Level 3: Subqueries & CTEs
* **Objective:** Solve comparative business problems using intermediate subqueries and modular CTE structures.
* **Key Insights:** Compared individual product prices against overall and subcategory averages, ranked top-spending customers using CTEs, and isolated products with zero sales history.

### 📊 Level 4: Advanced Window Functions
* **Objective:** Perform advanced analytical calculations without collapsing dataset rows.
* **Key Insights:** Ranked sales territories by total revenue (`DENSE_RANK`), tracked customer ordering habits (`FIRST_VALUE`), calculated month-over-month sales differences (`LAG`), extracted top 3 best-selling products per category (`ROW_NUMBER`), and computed a 3-month moving average of total sales.

### 🔍 Level 5: Correlated Subqueries & Anti-Semi Joins
* **Objective:** Handle high-complexity relational filtering and operational business audits.
* **Key Insights:** Isolated products priced above their specific subcategory average, tracked customers spending above regional averages, implemented Anti-Semi Joins (`NOT EXISTS`) to find products never ordered and customers inactive in specific years, and analyzed department-level employee salary distributions.

---

## 💻 Sample Query Highlight: Anti-Semi Join
Here is an example of a high-level **Anti-Semi Join** used to isolate products that have never been ordered, helping the procurement team make inventory decisions:

```sql
-- Finding products never ordered (Anti-Semi Join)
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

🗄️ About the Database
Database: AdventureWorks (MS SQL Server Sample Database provided by Microsoft).

Core Schemas Used: Production, Sales, Person, and HumanResources.

Note: Since AdventureWorks is a standard sample database, raw database files are not uploaded here; you can easily attach AdventureWorks to your local SQL Server instance to run the scripts.
