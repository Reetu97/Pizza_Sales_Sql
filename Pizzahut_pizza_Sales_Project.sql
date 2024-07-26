-- Retrieve the total number of orders placed.
Select count(order_id)
from orders;
-- Calculate the total revenue generated from pizza sales.
Select 
sum(order_details.quantity* pizzas.price) as total_sales
from order_details
JOIN pizzas
ON order_details.pizza_id= pizzas.pizza_id
-- Identify the highest-priced pizza.
Select pizza_types.name,pizzas.price
from pizza_types join pizzas on
pizza_types.pizza_type_id=pizzas.pizza_type_id
order by pizzas.price desc;
-- Identify the most common pizza size ordered.
select sum(order_details.quantity) as sum,pizzas.size
from order_details
join pizzas on order_details.pizza_id= pizzas.pizza_id
group by pizzas.size
order by sum desc;
-- List the top 5 most ordered pizza types along with their quantities.
select count(order_details.quantity) as c, pizzas.pizza_type_id
from order_details
JOIN pizzas on order_details.pizza_id=pizzas.pizza_id
group by pizzas.pizza_type_id
order by c desc
LIMIT 5
-- Join the necessary tables to find the total quantity of each pizza category ordered.
Select sum(order_details.quantity) as s,pizza_types.category
from order_details
join pizzas on order_details.pizza_id= pizzas.pizza_id
join pizza_types on pizzas.pizza_type_id= pizza_types.pizza_type_id
group by pizza_types.category
order by s desc;
-- Determine the distribution of orders by hour of the day.
select 
hour(order_time) as order_hour, count(order_id)
from orders
group by order_hour;
-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types
group by category;
-- Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(quantity) from 
(select orders.order_date, sum(order_details.quantity) as quantity
from orders
join order_details on orders.order_id= order_details.order_id
group by orders.order_date) as order_quantity
-- Determine the top 3 most ordered pizza types based on revenue.
select pizzas.pizza_type_id, sum(pizzas.price * order_details.quantity) as s
from pizzas
JOIN order_details on pizzas.pizza_id= order_details.pizza_id
group by pizzas.pizza_type_id
order by s desc
LIMIT 3
-- Calculate the percentage contribution of each pizza type to total revenue.
-- Step 1: Calculate the Total Revenue
with total_revenue as(
select sum(pizzas.price * order_details.quantity) as total_revenue
from pizzas
join order_details on pizzas.pizza_id= order_details.pizza_id
),
-- Step 2: Calculate Revenue by Pizza Type
revenue_by_pizza_type As(
select pizza_types.category, sum(pizzas.price * order_details.quantity) as revenue
from pizza_types
join pizzas on pizza_types.pizza_type_id= pizzas.pizza_type_id
join order_details on pizzas.pizza_id= order_details.pizza_id
group by pizza_types.category
)
-- Step 3: Calculate Percentage Contribution
select
revenue_by_pizza_type.category,
revenue_by_pizza_type.revenue,
(revenue_by_pizza_type.revenue/total_revenue.total_revenue)*100 As percentage_contribution
from
revenue_by_pizza_type, total_revenue;

-- Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue) over (order by order_date) as cum_revenue
from 
(select orders.order_date, sum(order_details.quantity*pizzas.price) as revenue
from orders
join order_details on orders.order_id=order_details.order_id
join pizzas on order_details.pizza_id= pizzas.pizza_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue
from 
(select category, name,revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.name, pizza_types.category, sum(order_details.quantity*pizzas.price) as revenue
from pizza_types
join pizzas on pizza_types.pizza_type_id= pizzas.pizza_type_id
join order_details on pizzas.pizza_id= order_details.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b
where rn<=3;

