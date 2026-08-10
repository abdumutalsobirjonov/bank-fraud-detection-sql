/*
========================================================================================================================================================
Customer Report
========================================================================================================================================================
Purpose:
    - This report consolidates key customer metrics and behaviours.

Highlights:
    1. Gathers essential fields such as customer name, birthdate, amount and city  DONE 
    2. Segments customers by amount to identify High-Performers, Mid-Range, or Low-Performers. DONE
    3. Aggregates customer-level metrics: DONE
        - total transactions 
        - total spending amount
        - lifespan (in months)
    4. Calculates valuable KPIs: DONE 
        - recency (years since last spend)
        - average yearly spending
========================================================================================================================================================
*/

-- 1. Gathers essential fields such as customer name, birthdate, amount and city  -- 
WITH base_query AS (
SELECT
    f.amount,
    f.is_fraud,
    f.transaction_number,
    f.transaction_time,
    c.birth_date,
    c.city,
    c.credit_card_number,
    c.full_name,
    c.gender,
    c.job,
    c.[state] 
FROM dbo.fact_transactions AS f  
LEFT JOIN
    dbo.dim_customers AS c  
ON
    f.credit_card_number = c.credit_card_number
      --  3. Aggregates customer-level metrics: --
), aggregates AS (                      
SELECT
    credit_card_number,
    full_name,
    DATEDIFF(YEAR,birth_date,GETDATE()) AS customer_age,
    gender,
    job,
    city,
    [state],
    DATEDIFF(MONTH,MIN(transaction_time),MAX(transaction_time)) AS lifespan,
    MAX(transaction_time) AS last_transaction_time,
    COUNT(transaction_number) AS total_transactions,
    SUM(amount) AS total_spend,
    SUM(CAST(is_fraud AS INT)) AS fraud_count
FROM base_query
GROUP BY
    credit_card_number,
    full_name,
    birth_date,
    gender,
    job,
    city,
    [state]
  -- 2. Segments customers by revenue to identify High-Performers, Mid-Range, or Low-Performers. --
), segmentation AS (
SELECT
    credit_card_number,
    full_name,
    customer_age,
    gender,
    job,
    city,
    [state],
    lifespan,
    last_transaction_time,
    total_transactions,
    total_spend,
    fraud_count,
    CASE 
        WHEN customer_age BETWEEN 18 AND 25 THEN 'Young_Age'
        WHEN customer_age BETWEEN 26 AND 35 THEN 'Adult_Age'
        WHEN customer_age BETWEEN 36 AND 50 THEN 'Middle_Age'
        WHEN customer_age BETWEEN 51 AND 65 THEN 'Pre_Retirement'
        ELSE 'Senior'
    END AS age_segment,
    CASE 
        WHEN  total_spend >  50000 THEN 'High-Performers'
        WHEN  total_spend > 15000 THEN 'Mid-Range'
        ELSE                            'Low-Performers'
    END AS customer_segment
FROM aggregates
      -- 4. Calculates valuable KPIs: --
), finish AS (
SELECT
    credit_card_number,
    full_name,
    customer_age,
    gender,
    age_segment,
    customer_segment,
    job,
    city,
    [state],
    lifespan,
    last_transaction_time,
    total_transactions,
    ROUND(CAST(total_spend AS MONEY),1) AS total_spend,
    fraud_count,
    ROUND(CAST(CASE 
        WHEN total_transactions = 0 THEN 0
        ELSE total_spend / total_transactions
    END AS MONEY),2) AS avg_transaction_spend,
    CAST(CASE 
        WHEN lifespan = 0 THEN total_spend
        ELSE total_spend / lifespan
    END AS MONEY) AS avg_monthly_spend,
    DATEDIFF(YEAR,last_transaction_time,GETDATE()) AS recency_years
FROM segmentation
) -- FINISH --
SELECT
    credit_card_number,
    full_name,
    customer_age,
    gender,
    age_segment,
    customer_segment,
    job,
    city,
    [state],
    lifespan,
    total_transactions,
    total_spend,
    fraud_count,
    avg_transaction_spend,
    avg_monthly_spend,
    recency_years
FROM finish
