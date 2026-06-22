# Databricks notebook source
from pyspark.sql.functions import sum as _sum, count, avg, countDistinct, col, when, round as _round

orders_enriched = spark.table("silver.orders_enriched")
order_details_enriched = spark.table("silver.order_details_enriched")
monthly_totals = spark.table("bronze.monthly_member_totals")

# ===== Objective 1: Restaurant Revenue & Cuisine Trends =====

revenue_by_restaurant = (orders_enriched
    .groupBy("restaurant_name", "restaurant_type", "restaurant_city")
    .agg(countDistinct("order_id").alias("total_orders"),
         _sum("total_order").alias("total_revenue"),
         avg("total_order").alias("avg_order_value"))
    .orderBy(col("total_revenue").desc())
)
revenue_by_restaurant.write.format("delta").mode("overwrite").saveAsTable("gold.revenue_by_restaurant")

revenue_by_cuisine = (orders_enriched
    .groupBy("restaurant_type")
    .agg(countDistinct("order_id").alias("total_orders"),
         _sum("total_order").alias("total_revenue"))
    .orderBy(col("total_revenue").desc())
)
revenue_by_cuisine.write.format("delta").mode("overwrite").saveAsTable("gold.revenue_by_cuisine")

revenue_by_meal_type = (order_details_enriched
    .groupBy("meal_type", "serve_type")
    .agg(count("*").alias("times_ordered"), _sum("price").alias("total_revenue"))
    .orderBy(col("total_revenue").desc())
)
revenue_by_meal_type.write.format("delta").mode("overwrite").saveAsTable("gold.revenue_by_meal_type")

# ===== Objective 2: Customer Spending & Budget Behavior =====

member_budget_status = (monthly_totals
    .withColumn("is_overspending", col("total_expense") > col("monthly_budget"))
    .withColumn("pct_of_budget_used", _round((col("total_expense") / col("monthly_budget")) * 100, 1))
)
member_budget_status.write.format("delta").mode("overwrite").saveAsTable("gold.member_budget_status")
display(monthly_totals.limit(20))


top_spenders = (monthly_totals
    .groupBy("member_id", "first_name", "surname", "city")
    .agg(_sum("total_expense").alias("lifetime_expense"),
         avg("monthly_budget").alias("avg_monthly_budget"),
         _sum(when(col("total_expense") > col("monthly_budget"), 1).otherwise(0)).alias("months_overspent"))
    .orderBy(col("lifetime_expense").desc())
)
top_spenders.write.format("delta").mode("overwrite").saveAsTable("gold.top_spenders")

print("✅ Gold tables built — ready for the dashboard!")