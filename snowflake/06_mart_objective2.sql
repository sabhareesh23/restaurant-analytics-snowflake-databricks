-- ============================================================
-- 06_mart_objective2.sql
-- Business Objective 2: Customer Spending & Budget Behavior
-- "Which members overspend their monthly budget? Who are the
--  top spenders? Any risk patterns?"
-- ============================================================

USE DATABASE FINAL_PROJECT;
USE SCHEMA MART;

-- Per-member, per-month spending vs budget (the core "overspend" table)
CREATE OR REPLACE TABLE MART.MEMBER_BUDGET_STATUS AS
SELECT
    member_id,
    first_name,
    surname,
    city,
    year,
    month,
    order_count,
    meals_count,
    monthly_budget,
    total_expense,
    balance,
    commission,
    CASE WHEN total_expense > monthly_budget THEN TRUE ELSE FALSE END AS is_overspending,
    ROUND( (total_expense / NULLIF(monthly_budget, 0)) * 100, 1) AS pct_of_budget_used
FROM RAW.MONTHLY_MEMBER_TOTALS;

-- Top spenders overall (lifetime, across all months in the data)
CREATE OR REPLACE TABLE MART.TOP_SPENDERS AS
SELECT
    member_id,
    first_name,
    surname,
    city,
    SUM(total_expense)  AS lifetime_expense,
    AVG(monthly_budget) AS avg_monthly_budget,
    SUM(CASE WHEN total_expense > monthly_budget THEN 1 ELSE 0 END) AS months_overspent
FROM RAW.MONTHLY_MEMBER_TOTALS
GROUP BY member_id, first_name, surname, city
ORDER BY lifetime_expense DESC;

-- Risk segments: how many members consistently overspend?
CREATE OR REPLACE TABLE MART.OVERSPEND_RISK_SEGMENTS AS
SELECT
    months_overspent,
    COUNT(*) AS num_members
FROM (
    SELECT
        member_id,
        SUM(CASE WHEN total_expense > monthly_budget THEN 1 ELSE 0 END) AS months_overspent
    FROM RAW.MONTHLY_MEMBER_TOTALS
    GROUP BY member_id
)
GROUP BY months_overspent
ORDER BY months_overspent;

-- Spending by city (geographic pattern)
CREATE OR REPLACE TABLE MART.SPENDING_BY_CITY AS
SELECT
    city,
    COUNT(DISTINCT member_id) AS num_members,
    SUM(total_expense)        AS total_expense,
    AVG(total_expense)        AS avg_expense_per_member_month
FROM RAW.MONTHLY_MEMBER_TOTALS
GROUP BY city
ORDER BY total_expense DESC;
