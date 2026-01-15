# SQL-Portfolio
Advanced SQL Portfolio: End-to-end Data Engineering and Analytics projects featuring T-SQL, ETL pipelines, and complex business reporting.

## Technical Skills Demonstrated
* **Database Design:** Relational modeling, normalization (1NF-3NF), and integrity constraints.
* **ETL & Data Ingestion:** XML usage, string manipulation (CROSS APPLY, STRING_SPLIT).
* **Advanced Analytics:** Common Table Expressions (CTEs), Window Functions (RANK), and hierarchical aggregations (ROLLUP).
* **Optimization:** Schema indexing and query logic refactoring.

---

## Project 1: Property Management & Automation System
**Filename:** `properties.sql`

A backend system designed to manage residential buildings, residents, and automated billing.
* **Key Feature:** Implemented **XML parsing** to ingest apartment data from external sources into a normalized schema.
* **Logic:** Created **User-Defined Functions** for dynamic fee calculation based on unit price and square footage.
* **Integrity:** Used FOREIGN KEY relationships and CHECK constraints to ensure data consistency across buildings and residents.

## Project 2: Pizza Delivery Data Pipeline
**Filename:** `pizzaanalysis.sql`

Transformation of unstructured order data into a clean, relational reporting structure.
* **Key Feature:** Utilized **CTEs and normalization** to refactor complex procedural logic into readable, maintainable code blocks.
* **Manipulation:** Applied `STRING_SPLIT` and `CROSS APPLY` to normalize multi-value ingredient columns.
* **Reporting:** Built aggregated views to analyze ingredient frequency across different pizza categories.

## Project 3: Music Sales Business Intelligence
**Filename:** `music_sales_analytics.sql`

A multi-level reporting tool for global music sales data on the chinook database.
* **Key Feature:** Employed **ROLLUP** and **GROUPING** functions to generate hierarchical totals.
* **Analytics:** Used **Window Functions** (`RANK()`) to identify top-performing genres while filtering out outliers.
* **Optimization:** Refactored multiple joins into optimized CTEs to improve query performance and readability.
