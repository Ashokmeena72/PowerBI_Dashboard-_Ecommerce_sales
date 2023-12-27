

--- 1.	Customer Demographics Analysis: 
---       •	Explore the distribution of customers based on gender and location.
---       •	Analyze the tenure_months to understand the average length of time customers have been with the business.


select Gender,
count (distinct customerID) as count_of_customer ---  what is distinct need to be counted 
from sales
group by gender


select location ,
count (distinct customerID) as count_of_customer,
Gender
from sales
group by location, Gender
order by Location,Gender





select round (sum(Online_sales),2) as total_sales
from sales 

select sum (online_sales) as online_sale_gender,gender
from sales
group by Gender  --- sales by gender 


---2.

/*2.	Geographical Insights:
•	Study location-wise sales to identify regions with high or low sales.
•	Analyze if there are any location-specific patterns in product preferences or purchasing behavior.*/

select * from sales

select round(sum (online_sales),2) as Online_sales_Regionwise, Location
from sales 
group by Location
order by Online_sales_Regionwise desc -- sum By region wise 


select Location,Gender,  count (distinct CustomerID ) as customer_count, round (sum (online_sales),2) as Online_sales_Regionwise
from sales 
group by Location, Gender
order by Gender,Online_sales_Regionwise desc  -- sum By region wise and genderwise 


select location,gender,AVG(tenure_months) as avg_tenure,round (sum (online_sales),2) as Online_sales_Regionwise
from sales 
group by location,Gender
order by Online_sales_Regionwise desc


with sales_region as 
(
select location ,gender,count (distinct CustomerID ) as customer_count,AVG(tenure_months) as avg_tenure,round (sum (online_sales),2) as Online_sales_Regionwise
from sales 
group by location,Gender
)
SELECT
    SR.Location,
    SR.Gender,
   SR.Online_sales_Regionwise Online_sales_Regionwise,
    SR.customer_count,
   SR.avg_tenure avg_tenure,
    Online_sales_Regionwise / SUM(Online_sales_Regionwise) OVER (PARTITION BY location) * 100 AS gender_share_percent  ---- new things sum as window function
FROM
    sales_region sr
	order by sr.Location,sr.Gender  ---   this gives as  % share of sales  according female /male  in each region 


	with sales_by_region as 
(
select location , CustomerID,sum(online_sales) as Total_online_sale,
ROW_NUMBER()over (partition by location order by sum(online_sales) Desc) as rn
from sales
group by location ,CustomerID 
)
select Sr.location,sr.rn,SR.customerid,Sr.Total_online_sale
from sales_by_region SR
where rn < =3
order by sr.location , Sr.Total_online_sale desc ---- this gives top 30 customer by region wise arrnged in descig order 



----- 
/*3.	Product Insights:
•	Examine the most popular product categories and products based on sales quantity or amount.
•	Calculate the average price and delivery charges for each product category.*/


select * from sales 

with Product_category_rank as
(
select gender,product_category,
round (sum (online_sales),2) as total_sales,
row_number() over 
( partition by gender order by round (sum (online_sales),2) Desc) as category_rank
from sales 
group by gender, 
product_category
)
select p.gender,p.product_category,
p.total_sales
from Product_category_rank P
where p.category_rank <= 5
order by P.gender ,P.total_sales desc


with Product_category_rank as
(
select gender,product_category,
round (sum (online_sales),2) as total_sales,
row_number() over 
( partition by gender order by round (sum (online_sales),2) Desc) as category_rank
from sales 
group by gender, 
product_category
)
select p.gender,p.product_category,
p.total_sales
from Product_category_rank P
where p.category_rank <= 5
order by P.gender ,P.total_sales desc







select * from sales 

with Product as
(
select gender,Product_Description,round (sum (online_sales),2) as total_sales,
row_number() over ( partition by gender order by round (sum (online_sales),2) Desc) as category_rank
from sales 
group by gender , Product_Description
)
select p.gender,p.Product_Description,p.total_sales
from Product P
where p.category_rank <= 5
order by P.gender ,P.total_sales desc




select  Product_Category, round (sum (online_sales),2) as total_sales
from sales
group by Product_Category
order by total_sales desc  --- sales by product category  --- popular product category 


select top 10 Product_Category, 
round (sum (online_sales),2) as total_sales
from sales
group by Product_Category
order by total_sales desc  ---top 10 sales by product category 


select Location, Product_Category, round (sum (online_sales),2) as total_sales,
dense_rank() over (partition by location order by round (sum (online_sales),2) desc) as Productsale_rank
from sales
group by location,Product_Category
order by Location,total_sales desc ---- top seller product category region wise 


with Prodcut_sale_by_region as 
(
select Location, Product_Category,
round (sum (online_sales),2) as total_sales,
dense_rank() over 
(partition by location order by round (sum (online_sales),2) desc) as Productsale_rank
from sales
group by location,Product_Category
)
select  ps.Location,ps.Productsale_rank,
ps.product_category,ps.total_sales
from Prodcut_sale_by_region ps 
where ps.Productsale_rank <=3
order by ps.Location,ps.total_sales desc   --- top 3 selling product category  region wise 


 with quantity_region as 
 (
select location, product_category ,sum (quantity) as total_quantity ,
dense_rank() over (partition by location order by count (quantity)desc) as DEnserank
from sales
group by location ,product_category --- quantity of product  sold within region 
)
select  QR.location,Qr.product_category,Qr.total_quantity
from quantity_region qr
where qr.denserank <=3
order by qr.location,Qr.total_quantity desc   ---  quanity of product sold by region


select location,product_category,Product_Description,sum (quantity) as total_quantity,
round (sum(online_sales),2) as total_sales,
row_number() over (partition by location order by round (sum(online_sales),2) ) as regional_quantity 
from sales
group by location,product_category,Product_Description --- under product category quantity of items sold region wise 
order by location,total_quantity desc


/*4.	Basket Analysis:
•	Explore which products are frequently purchased together. This can inform bundling strategies or recommendations.-*/
select * from sales

select top 10 product_description,
count(product_sku) as product_basket
from sales
group by Product_Description
order by product_basket desc

select * from sales 
where transaction_id =32526

select transaction_id,count(transaction_id) as repeatted
from sales 
group by Transaction_ID
order by repeatted desc 

WITH Basket AS (
SELECT Transaction_ID,
STRING_AGG(Product_Description, ', ') AS ProductCombination
FROM sales
GROUP BY Transaction_ID
)
SELECT ProductCombination,
COUNT(Transaction_ID) AS TransactionCount
FROM Basket
WHERE ProductCombination IS NOT NULL AND LEN(ProductCombination) > 0
GROUP BY ProductCombination
ORDER BY TransactionCount DESC; --- unique prodct combination

--
/*4.	Time Series Analysis:
•	Conduct time series analysis on transaction dates to identify any recurring patterns or anomalies.*/
	WITH CTR AS 
(
SELECT MONTH,COUNT(TRANSACTION_ID) AS total_count_transaction,
LAG(COUNT(TRANSACTION_ID)) OVER (ORDER BY MONTH) AS prev_month_transaction_count,
CASE WHEN LAG(COUNT(TRANSACTION_ID)) OVER (ORDER BY MONTH) IS NULL THEN NULL
ELSE (((COUNT(TRANSACTION_ID) - LAG(COUNT(TRANSACTION_ID)) OVER (ORDER BY MONTH)) * 100.0) / LAG(COUNT(TRANSACTION_ID)) OVER (ORDER BY MONTH))
END AS month_on_month_increase_percentage 
FROM sales
GROUP BY MONTH
)
SELECT MONTH,total_count_transaction,
month_on_month_increase_percentage
FROM CTR
ORDER BY MONTH;---------- this gives % chnge over month on transaction


select location ,month , count (transaction_id) as total_count_trasaction,
round (sum(online_sales),2) as monthly_sales_amount,
lag (round (sum(online_sales),2)) over (partition by location order by month) as previous_month_sale,
case 
when lag (round (sum(online_sales),2)) over (partition by location order by month) is null then null
else (round (sum(online_sales),2)-lag (round (sum(online_sales),2)) over (partition by location order by month))/lag (round (sum(online_sales),2)) over (partition by location order by month) * 100.00
end as percentage_change_over_months
from sales
group by Month,Location
order by location,Month   --- % change in every region months wise 



/*3.	Popular Transaction Days/Time:
•	Determine the most popular days or times for transactions. This can help in optimizing marketing or promotional activities.*/
select Month, count (distinct transaction_id) as Popular_day_transaction_count
from sales 
group by Month
order by Popular_day_transaction_count desc


/*5	Effectiveness of Discounts/Coupons over Time:
•	Evaluate whether the impact of discounts or coupons changes over time. Identify trends in customer responsiveness to promotional offers.
*/
WITH DiscountSummary AS (
SELECT Discount_pct,SUM(Online_sales) AS total_online_sales
FROM sales
GROUP BY Discount_pct
)
SELECT
Discount_pct,
total_online_sales,
(total_online_sales - LAG(total_online_sales) OVER (ORDER BY Discount_pct)) / LAG(total_online_sales) OVER (ORDER BY Discount_pct) * 100.0 AS sales_percentage_change
FROM DiscountSummary
ORDER BY Discount_pct;


select coupon_status,count(*) as total_count
from sales
group by Coupon_Status


SELECT coupon_status,
COUNT(*) AS total_count,
(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()) AS percentage  ----- new learning 
FROM sales
GROUP BY coupon_status

select discount_pct,Coupon_Status,count(*) as total_count,
count(*)*100.00/ sum(count(*)) over () as percetage_share
from sales
group by Discount_pct,Coupon_Status
order by Discount_pct

select distinct Transaction_Date, month,COUNT (distinct Transaction_ID) as count_of_transaction, round (sum(online_sales),2) as total_sales
from sales 
group by Month,Transaction_Date
order by total_sales desc

select Location,month,coupon_status,discount_pct, gender ,count(transaction_id) as count_transaction,round (sum (online_sales),2) as sales
from sales 
group by location,month,Coupon_Status,discount_pct,Gender
order by Location,Month


select discount_pct, count (Transaction_id)
from sales
group by discount_pct    --- cutomer breakup for who used coupon code
order by Discount_pct

select 

select gender,coupon_status,discount_pct, count (Transaction_id) as countOf_transaction
,round (sum (online_sales),2) as total_sales 
from sales
group by Coupon_Status,discount_pct ,gender
order by gender,total_sales desc


/*5.	Discount Analysis:
•	Explore the distribution of discount percentages (Discount_pct) to identify any patterns or trends.
•	Examine the relationship between discounts and transaction amounts.*/

select * from sales

select discount_pct,  round (sum (online_sales),2) as Total_sales
--lag (round(sum(online_sales),2)) over (partition by discount_pct order by round (sum (online_sales),2))
from sales
group by Discount_pct
order by Discount_pct asc


with Discount as 
(
select  month ,discount_pct, 
round( sum (online_sales),2) as total_sales
from sales
group by  month, Discount_pct
)
select month ,DI.discount_pct,di.total_sales,
(di.total_sales- lag(di.total_sales) over 
(order by month))/lag(di.total_sales) over 
( order by month)*100 as Percntage_change
from discount di
order by  month

	----
select  month ,discount_pct, round( sum (online_sales),2) as total_sales
from sales
group by  month, Discount_pct
order by month


