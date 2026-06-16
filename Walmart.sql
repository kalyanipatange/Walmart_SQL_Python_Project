-- Walmart SQL Project--

select * from walmart_clean_data;
select count(*) from walmart_clean_data;
-- Count payment methods and number of transactions by payment method

select payment_method ,count(payment_method) as no_of_Transaction from walmart_clean_data
group by 1 ;

-- Count distinct branches
select  count(distinct branch) from walmart_clean_data;

-- Find the minimum quantity sold
select min(quantity) from walmart_clean_data;

-- Business Problem --
-- Q1: Find different payment methods, number of transactions, and quantity sold by payment method

select payment_method,count(*) as no_of_transaction , sum(quantity) as quantity_sold from walmart_clean_data
group by 1 ;

-- Project Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
select branch, category, avg_rating ,rnk from 
(select branch ,category ,avg(rating ) as avg_rating, rank() over(partition by  branch order by avg(rating ) desc) as rnk from walmart_clean_data
group by 1,2) as ranked 

where rnk=1;

-- Q4: Calculate the total quantity of items sold per payment method

select * from walmart_clean_data;
select  payment_method , sum(quantity) as total_quantity from walmart_clean_data
group by 1;

-- Q3: Identify the busiest day for each branch based on the number of transactions

select str_to_date( date ,'%y-%m-%d') as converted_date from walmart_clean_data;

ALTER TABLE walmart_clean_data 
MODIFY COLUMN date DATE;


Select *  from 
(select Branch,  dayname(date) as Days ,count(*) as no_of_transaction, rank() over( partition by branch order by count(*) desc) as rnk
 from walmart_clean_data
group by 1 ,2 ) as ranked 
where rnk=1;
-- Q5: Determine the average, minimum, and maximum rating of categories for each city

select city , category , round (avg(rating),1) as average_rating , min(rating) as Minimum_rating ,
max(rating) as maximum_rating from walmart_clean_data
group by 1,2;

-- Q6: Calculate the total profit for each category
select category , round(sum(total * profit_margin),2)  as total_profit from walmart_clean_data
group by 1 ;

-- Q7: Determine the most common payment method for each branch 
with CTE as 
(select branch, payment_method, count(*) as no_of_transaction , RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
 from walmart_clean_data group by 1,2 ) 
SELECT branch, payment_method AS preferred_payment_method
FROM CTE
WHERE rnk = 1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts

select Branch,
case when (hour(time))< 12 then 'morning'
when (hour(time)) between 12 and 17 then 'Afternoon'
else 'evening' 
end as shift,
count(*) as num_invoices from walmart_clean_data
group by Branch, shift 
order by Branch, num_invoices desc; 


-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

with revenue_2022 as (

select branch , sum(total) as revenue  from walmart_clean_data 
where year(date)=2022 group by 1) ,

revenue_2023 as (

select branch , sum(total) as revenue  from walmart_clean_data 
where year(date)=2023 group by 1) 

SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;