/*
====================================================================================================
Merchant Report
====================================================================================================
Purpose:
    - This report consolidates key Merchant metrics and behaviors.

Highlights:
    1. Gathers essential fields such as merchant name, category ... -- DONE --
    2. Segments merchants by revenue to identify High-Performers, Mid-Range, or Low-Performers
    3. Aggregates merchant-level metrics: -- DONE --
        - total transactions
        - total revenue amount
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (years since last transaction)
        - average yearly revenue
====================================================================================================
*/
  --  1. Gathers essential fields such as merchant name, category ... --
WITH base_query AS (
SELECT
    f.amount,
    f.transaction_number,
    f.is_fraud,
    f.transaction_time,
    m.category,
    m.merchant
FROM dbo.fact_transactions AS f  
LEFT JOIN
    dbo.dim_merchants AS m 
ON
    f.merchant = m.merchant 
      --  3. Aggregates merchant-level metrics: --
), aggregations AS (
SELECT
    merchant,
    category,
    DATEDIFF(MONTH,MIN(transaction_time),MAX(transaction_time)) AS lifespan_monthly,
    MAX(transaction_time) AS last_transaction_time,
    COUNT(transaction_number) AS total_transactions,
    SUM(amount) AS total_revenue,
    SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_count
FROM base_query 
GROUP BY
    merchant,
    category
    -- 2. Segments merchants by revenue to identify High-Performers, Mid-Range, or Low-Performers / 4. Calculates valuable KPIs: -- 
), finish AS (
SELECT
merchant,
category,
lifespan_monthly,
total_transactions,
total_revenue,
fraud_count,
CASE 
    WHEN total_revenue >= 100000 THEN 'High-Performers'
    WHEN total_revenue >= 50000 THEN 'Mid-Range'
    ELSE 'Low-Performers'
END AS merchant_segment,
CASE 
    WHEN fraud_count >= 10 THEN 'High_Fraud_Count'
    WHEN fraud_count >= 1  THEN 'Low_Fraud_Count'
    ELSE 'Zero_Fraud_Count'
END AS fraud_segment,
DATEDIFF(YEAR,last_transaction_time,GETDATE()) AS recency_years,
lifespan_monthly / 12.0 AS lifespan_yearly,
CASE 
    WHEN lifespan_monthly / 12.0 = 0 THEN total_revenue
    ELSE total_revenue / (lifespan_monthly / 12.0)
END AS avg_yearly_revenue
FROM aggregations
)
SELECT
    merchant,
    merchant_segment,
    lifespan_monthly,
    total_transactions,
    total_revenue,
    fraud_count,
    fraud_segment,
    recency_years,
    avg_yearly_revenue
FROM finish
