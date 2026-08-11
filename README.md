# bank-fraud-detection-sql
SQL Server fraud detection analysis using a star schema, Python data cleaning, and window functions to identify fraud patterns by customer and merchant.
## Purpose
The purpose of this project is to detect fraud transactions and analyze customer and merchant behavior across 1.3 million+ transaction records. Using a star schema and RFM-style segmentation, the project identifies fraud patterns and generates business insights through two detailed reports.

## Tools Used
- SQL Server (Docker)
- Python (pandas)
- Power BI

## Approach
Raw data was cleaned and transformed using Python, then loaded into SQL Server and structured into a star schema. Multi-step CTE queries (base_query -> aggregations -> segmentation -> finish) were used to build two detailed reports — Customer Report and Merchant Report. Each report applies RFM-style segmentation (Recency, Frequency, Monetary) to classify customers and merchants into performance tiers, and separately classifies them by fraud risk level using a fraud_segment breakdown.


## Key Findings
1. **Customer spend concentration** — Low-Performers customers make up 7.6% of all customers but account for only 0.5% of total spend, while High-Performers (72% of customers) drive 92% of total spend.
2. **Merchant revenue concentration** — High-Performers merchants make up 60% of all merchants but generate 75% of total revenue.
3. **Fraud concentrated in high-revenue merchants** — High-Performers merchants account for only 60% of all merchants but are responsible for 85% of all flagged fraud transactions, suggesting revenue and fraud risk are strongly correlated.
4. **Unexpected fraud pattern in low-spend customers** — Low-Performers customers average 9.88 fraud transactions per customer, higher than both Mid-Range (7.01) and High-Performers (7.57), suggesting low-spend accounts may be under-monitored relative to their actual risk.

## Files
- `customer_report.sql` — Customer-level RFM segmentation and fraud analysis
- `merchant_report.sql` — Merchant-level revenue segmentation and fraud analysis
- `data_cleaning.ipynb` — Python-based data cleaning and preparation before loading into SQL Server
