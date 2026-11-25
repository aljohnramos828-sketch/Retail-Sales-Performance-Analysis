
# Project 1 — Retail Sales Performance Analysis
/*
Note: 
	All records are fictional and computer-generated for portfolio practice.
	No real customers, businesses, or transactions are represented.
*/

-- Data Inspection
-- Inspecting what kind of data we have before analysis
Select *
From customers
;

Select *
from products
;

Select *
from sales
;

Select *
from stores
;

-- DATA PREPARATION
-- Procedure: Column Renaming and Data Standardization

ALTER TABLE customers
RENAME COLUMN ï»¿customer_id TO customer_id;

ALTER TABLE sales
RENAME COLUMN ï»¿sale_id TO sale_id;

ALTER TABLE products
RENAME COLUMN ï»¿product_id TO product_id;

ALTER TABLE stores
RENAME COLUMN ï»¿store_id TO store_id;


-- Exploratory Data Analysis

-- Monthly Sales and Profit Performance Analysis
-- 1.1 How have monthly sales and profit changed over time?
Select DATE_FORMAT(sale_datetime, '%Y-%m') as date,
	 Round(sum(net_sales),2) total_net_sales,
	 Round(sum(profit),2) total_profit
from sales
Group by date
order by date;

-- 1.2 Identify the months with the highest and lowest sales.
Select DATE_FORMAT(sale_datetime, '%Y-%m') as date,
	 Round(sum(net_sales),2) total_net_sales
from sales
Group by date
order by total_net_sales DESC
Limit 5
;
-- 'May' consistently generate high net sale accross all three years.
-- However, November 2025 generate the highest net sale across all months.


Select DATE_FORMAT(sale_datetime, '%Y-%m') as date,
	 Round(sum(net_sales),2) total_net_sales
from sales
Group by date
order by total_net_sales
Limit 5
;
-- July 2026 generate the lowest  net sale across all months. 
-- Since July 2025 is also included in the top five this means that july actually the month that sales is low. 

-- 1.3 Identify the months with the highest profit.
Select DATE_FORMAT(sale_datetime, '%Y-%m') as date,
	 Round(sum(profit),2) total_profit
from sales
Group by date
order by total_profit DESC
Limit 5
;
-- November 2025 generate the most profit, this supports the claim for the highest generating net sale per month

-- Product Category Sales and Profitability Analysis
-- 2. Which product categories generate the most net sales and profit?
Select p.category,
	 Round(sum(s.net_sales),0) as total_net_sales,  
	 Round(sum(s.profit),0) as total_profit
from sales s
	join products p
	on s.product_id = p.product_id
Group by p.category
order by total_net_sales Desc, total_profit desc
;

-- Product Performance and Profit Margin Analysis
-- 3. Which products have high sales but weak profit margins?
Select product_name, Round(sum(net_sales),2) net_sale, Round(sum(profit),2) profit, Round(Sum(profit)/nullif(sum(net_sales),0),2) profit_margin
From sales s
join products p
	on s.product_id = p.product_id
Group by product_name
Order by net_sale DESC, profit_margin DESC
;
-- Laptop generates the highest profit, however, base on the profit margin, the profit only generate 44 pesos in every 100 pesos net sale

-- Regional and Store Performance Analysis
-- 4. Which regions and stores perform best in every category?
Select distinct category
From products
;

-- 4.1 Electronic
Select s.region,
		 s.store_name,
         Round(sum(net_sales),2) net_sale,
		round(sum(sa.profit),2) profit,
		Round(Sum(profit)/nullif(sum(net_sales),0),2) profit_margin,
        count(quantity) quantity_sold
From stores s
left join sales sa
on sa.store_id = s.store_id
left join products p
on p.product_id = sa.product_id
where category = 'Electronics'
group by region, store_name
order by net_sale DESC, profit DESC, profit_margin DESC
;

-- 4.2 Home & Living
Select s.region,
		 s.store_name,
         Round(sum(net_sales),2) net_sale,
		round(sum(sa.profit),2) profit,
		Round(Sum(profit)/nullif(sum(net_sales),0),2) profit_margin,
        count(quantity) quantity_sold
From stores s
left join sales sa
on sa.store_id = s.store_id
left join products p
on p.product_id = sa.product_id
where category = 'Home & Living'
group by region, store_name
order by net_sale DESC, profit DESC, profit_margin DESC
;

-- 4.3 Office Supplies
Select s.region,
		 s.store_name,
         Round(sum(net_sales),2) net_sale,
		round(sum(sa.profit),2) profit,
		Round(Sum(profit)/nullif(sum(net_sales),0),2) profit_margin,
        count(quantity) quantity_sold
From stores s
left join sales sa
on sa.store_id = s.store_id
left join products p
on p.product_id = sa.product_id
where category = 'Office Supplies'
group by region, store_name
order by net_sale DESC, profit DESC, profit_margin DESC
;

-- 4.4 Fashion
Select s.region,
		 s.store_name,
         Round(sum(net_sales),2) net_sale,
		round(sum(sa.profit),2) profit,
		Round(Sum(profit)/nullif(sum(net_sales),0),2) profit_margin,
        count(quantity) quantity_sold
From stores s
left join sales sa
on sa.store_id = s.store_id
left join products p
on p.product_id = sa.product_id
where category = 'Fashion'
group by region, store_name
order by net_sale DESC, profit DESC, profit_margin DESC
;

-- 4.5 Regardless of category/ For all Category
Select s.region,
		 s.store_name,
         Round(sum(net_sales),2) net_sale,
		round(sum(sa.profit),2) profit,
		Round(Sum(profit)/nullif(sum(net_sales),0),2) profit_margin,
        count(quantity) quantity_sold
From stores s
left join sales sa
on sa.store_id = s.store_id
left join products p
on p.product_id = sa.product_id
group by region, store_name
order by net_sale DESC, profit DESC, profit_margin DESC
;

-- Sales Channel Performance Analysis
-- 5. How do sales channels compare?
Select distinct sales_channel
From sales;

Select sales_channel,
		Round(sum(net_sales),2) net_sale,
		round(sum(profit),2) profit,
        Round(Sum(profit)/nullif(sum(net_sales),0),2) profit_margin
From sales
Group by sales_channel
order by  net_sale desc
;
-- Marketplace generate the highest net sale and profit per chanel.

-- Sales Returns and Order Cancellation Analysis
-- 6. What is the return and cancellation rate?
Select order_status, 
count(sale_id) num_sales, 
count(*)/sum(count(*)) OVER() as rate
From sales
group by order_status
;
-- 3% of the sales were returned and 2% of the sales were cancelled

-- Sales Channel Performance Analysis by Order Status.
-- 7. How many transactions are completed and returned across each sales channel?
Select order_status, sales_channel, count(*) num_sales
from sales
where order_status in ('Completed', 'Returned')
Group by order_status, sales_channel with rollup
Order by num_sales DESC
;

Select age_group, sum(net_sales) Total_net_sale
From sales s
left join  customers c
on s.customer_id = c.customer_id
Group by age_group
order by Total_net_sale Desc
;

-- Overall Business KPIs
-- 8. What are the overall sales KPIs?
Select count(*) num_transaction,
ROund(sum(net_sales),2) total_net_sales,
ROund(sum(profit),2) total_profit,
 Round(avg(net_sales),2) avg_net_sales,
 sum(quantity) total_item_sold,
 count(distinct product_name) num_product,
 count(distinct c.customer_id) num_customer
From sales s
left join products p
on s.product_id = p.product_id
left join customers c
on s.customer_id = c.customer_id
;


