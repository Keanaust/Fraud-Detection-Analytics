# SQL-Based Fraud Detection - E-Commerce Risk Analytics  

## Overview  
This project focuses on **fraud detection and risk analysis** in e-commerce transactions using **SQL-based analytics**. The objective is to identify **high-risk transactions**, detect **suspicious order patterns**, and enhance **fraud prevention strategies** by leveraging **advanced SQL queries**.

### About Northwind Traders  
The **Northwind Traders** dataset is a **sample e-commerce database** that simulates a **wholesale supplier**. The company **sells food and beverage products** to customers across multiple regions. The dataset contains **orders, products, suppliers, customers, employees, and shippers**, making it an **ideal dataset for fraud detection analysis**.

- **Orders Table** – Contains **customer transactions** with product and pricing details.  
- **Customers Table** – Holds **customer company names, countries, and contact details**.  
- **Order Details Table** – Captures **product quantity, unit price, and discount applied per order**.  

**Dataset Reference**: [Northwind Traders Sample Dataset](https://docs.yugabyte.com/preview/sample-data/northwind/)  

---

## Problem Statement  
### Challenges Identified:  
- Fraudulent transactions causing revenue losses.  
- High-risk customers making frequent **suspicious purchases**.  
- Lack of **real-time fraud detection** in structured databases.  

### Motivation:  
- **For Businesses**: Minimize fraud losses and optimize fraud detection rules.  
- **For Analysts**: Build an **SQL-driven fraud detection** framework that is **scalable**.  
- **For Compliance Teams**: Improve risk monitoring with structured fraud risk metrics.  

---

## Methodology & Query Overview  
### Methodology at a Glance  
1. **Data Collection**: Extracting transactional data from SQL databases.  
2. **Preprocessing**: Identifying missing values, handling duplicate transactions.  
3. **Risk Modeling**: Applying **CASE statements** to classify fraud risk levels.  
4. **Fraud Insights**: Aggregating data for fraud risk dashboards.  

---

## Fraud Detection Process  
### **Key Fraud Detection Strategies Used in SQL**
**Order Analysis** – Aggregates total order values, purchase frequency, and product price variations.  
**High-Risk Order Classification** – Uses **dynamic thresholds** to flag suspicious transactions.  
**Duplicate Transactions Detection** – Identifies customers placing multiple orders in a short period.  
**Price Manipulation Analysis** – Flags cases where a product is sold at **multiple distinct price points**.  
**Final Fraud Risk Report** – Merges all risk signals to provide a **comprehensive fraud summary**.  

---

## Files Included  
**SQL Script**  
- `fraud_detection_analysis.sql` → Full fraud detection SQL query.  

