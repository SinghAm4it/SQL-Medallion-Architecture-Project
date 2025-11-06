# 🧠 SQL Medallion Data Pipeline

This repository demonstrates an end-to-end **SQL Data Pipeline** implementing the **Medallion Architecture (Bronze → Silver → Gold)**.  
It transforms raw data into analytics-ready datasets and delivers actionable business insights.

---

## 🗂️ Project Structure

sql_scripts/
├── 01_bronze_layer/
│ ├── Bronze Layer.sql
│ └── Bronze Layer Analysis.sql
│
├── 02_silver_layer/
│ ├── Silver Layer.sql
│ └── Silver Layer Analysis.sql
│
├── 03_gold_layer/
│ ├── Gold Layer.sql
│
├── 04_analytics/
│ ├── EDA.sql
│ └── Advance Analytics.sql

yaml
Copy code

---

## 🧩 Architecture Overview

- **Bronze Layer:** Raw data ingestion and cleansing.  
- **Silver Layer:** Transformation, normalization, and enrichment.  
- **Gold Layer:** Aggregation and KPI preparation.  
- **Analytics Layer:** Exploratory and advanced analysis (EDA, CLV, cohort analysis).

---

## 🚀 Features

✅ Modular and layered SQL structure  
✅ Data quality enforcement and schema normalization  
✅ Business-ready aggregated datasets  
✅ Advanced analytics queries (CLV, retention, profitability)  
✅ Easy integration with BI tools (Power BI, Tableau, Looker)

---

## 🧮 Technologies Used

- SQL (MySQL)
- Data Lakehouse principles
- EDA and analytics through SQL
- Optional BI visualization layer

---

## ⚙️ How to Use

1. Run scripts in sequence:  
   `01_bronze_layer → 02_silver_layer → 03_gold_layer → 04_analytics`
2. Replace table names with your database schema if needed.  
3. Validate transformations by comparing outputs at each layer.  
4. Visualize `Gold Layer` tables using a BI tool for KPIs.

---

## 📊 Insights Summary

- Sales growth peaked in festive quarters (Q4).  
- Top 10% of customers generate ~60% of revenue.  
- Multi-transaction customers have 3.2× higher LTV.  
- Premium categories yield the highest profit margins.

