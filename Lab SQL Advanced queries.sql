-- Lab | SQL Rolling calculations
-- 1. Get number of monthly active customers.
select * from sakila.customer;
select * from sakila.rental;

create or replace view sakila.customer_activity as
select customer_id, rental_date as activity_date,
date_format(rental_date, '%m') as activity_month,
date_format(rental_date, '%Y') as activity_year
from sakila.rental;

create or replace view sakila.monthly_activity as
select activity_year, activity_month, count(distinct customer_id) as users 
from sakila.customer_activity
group by activity_year, activity_month
order by activity_year asc, activity_month asc;

-- 2. Active users in the previous month.
select *, lag(users) over () as prev_month_users
from sakila.monthly_activity;

-- 3. Percentage change in the number of active customers.
with cte1 as (
select *, lag(users) over () as prev_month_users
from sakila.monthly_activity
)
select *, round(((users-prev_month_users)/prev_month_users*100),2) as percent_change
from cte1;

-- 4. Retained customers every month.
create or replace view sakila.active_customers as
select distinct customer_id, 
date_format(rental_date, '%m') as activity_month,
date_format(rental_date, '%Y') as activity_year
from sakila.rental;

create or replace view sakila.recurrent_customers as
select a1.customer_id, a1.activity_year, a1.activity_month from active_customers a1
join active_customers a2
on a1.activity_year = a2.activity_year
and a1.activity_month = a2.activity_month+1
and a1.customer_id = a2.customer_id
order by a1.customer_id, a1.activity_year, a1.activity_month;

select * from recurrent_customers;

select activity_year, activity_month, count(customer_id) as retained_customers from recurrent_customers
group by activity_year, activity_month;
