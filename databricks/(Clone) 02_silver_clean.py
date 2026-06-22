# Databricks notebook source
from pyspark.sql.functions import col

orders = spark.table("bronze.orders")
restaurants = spark.table("bronze.restaurants")
restaurant_types = spark.table("bronze.restaurant_types")
cities = spark.table("bronze.cities")
order_details = spark.table("bronze.order_details")
meals = spark.table("bronze.meals")
meal_types = spark.table("bronze.meal_types")
serve_types = spark.table("bronze.serve_types")
members = spark.table("bronze.members")

# Orders enriched with restaurant + city + cuisine info
orders_enriched = (orders
    .join(restaurants, orders.restaurant_id == restaurants.id, "left")
    .join(restaurant_types, restaurants.restaurant_type_id == restaurant_types.id, "left")
    .join(cities, restaurants.city_id == cities.id, "left")
    .select(
        orders["id"].alias("order_id"), "order_date", "order_hour", "member_id", "total_order",
        restaurants["id"].alias("restaurant_id"), "restaurant_name", "restaurant_type",
        cities["city"].alias("restaurant_city")
    )
)
orders_enriched.write.format("delta").mode("overwrite").saveAsTable("silver.orders_enriched")

# Order details enriched with meal info
order_details_enriched = (order_details
    .join(meals, order_details.meal_id == meals.id, "left")
    .join(meal_types, meals.meal_type_id == meal_types.id, "left")
    .join(serve_types, meals.serve_type_id == serve_types.id, "left")
    .select(
        order_details["id"].alias("order_detail_id"), "order_id",
        meals["id"].alias("meal_id"), "meal_name", "price", "hot_cold", "meal_type", "serve_type"
    )
)
order_details_enriched.write.format("delta").mode("overwrite").saveAsTable("silver.order_details_enriched")

# Members enriched with city
members_enriched = (members
    .join(cities, members.city_id == cities.id, "left")
    .select(members["id"].alias("member_id"), "first_name", "surname", "sex", "email",
            "monthly_budget", cities["city"].alias("member_city"))
)
members_enriched.write.format("delta").mode("overwrite").saveAsTable("silver.members_enriched")

print("✅ Silver tables built:",
      orders_enriched.count(), order_details_enriched.count(), members_enriched.count())