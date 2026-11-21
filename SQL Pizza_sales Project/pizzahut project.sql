use pizzahut


--Retrieve the total number of orders placed.

select count(order_id) as total_number
from orders


--Calculate the total revenue generated from pizza sales.

SELECT round (
           sum (order_details.quantity * pizzas.price),
           2
       ) AS total_revenue
FROM   order_details
       INNER JOIN
       pizzas
       ON pizzas.pizza_id = order_details.pizza_id;  


      3 --Identify the highest-priced pizza.

      select pizza_types.name,pizzas.price
      from pizza_types join pizzas
      on pizza_types.pizza_type_id = pizzas.pizza_type_id
      order by pizzas.price 
      desc


       4-- Identify the most common pizza size ordered.

        select pizzas.size,count(order_details.order_details_id) as order_count

       from pizzas join order_details on pizzas.pizza_id = order_details.pizza_id
       group by pizzas.size
       order by order_count desc


      5  --List the top 5 most ordered pizza types 
         --along with their quantities.

         select pizza_types.name,
         sum(order_details.quantity) AS quantity
         from pizza_types join pizzas
         on pizza_types.pizza_type_id = pizzas.pizza_type_id
         join order_details on order_details.pizza_id = pizzas.pizza_id 
         group by pizza_types.name
         order by quantity desc



         --intermediate


        6 --Join the necessary tables to find the total quantity of each pizza category ordered.

        select pizza_types.category,
        SUM(order_details.quantity) as quantity
        from pizza_types join pizzas
        on pizza_types.pizza_type_id =pizzas.pizza_type_id
        join order_details on order_details.pizza_id = pizzas.pizza_id
        group by pizza_types.category order by quantity desc



 7   --Determine the distribution of orders by hour of the day.
 select * from orders
 SELECT
    DATEPART(HOUR,time) AS hour,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY DATEPART(HOUR, time)
ORDER BY hour


--Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) from pizza_types
group by category


--Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
(
    SELECT
        orders.time,
        SUM(order_details.quantity) AS quantity
    FROM orders
    INNER JOIN order_details 
        ON orders.order_id = order_details.order_id
    GROUP BY orders.time
) AS order_quantity



--10 __Determine the top 3 most ordered pizza types based on revenue.


SELECT top 3
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
INNER JOIN pizzas
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
INNER JOIN order_details
    ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC




--ADVANCED--

--Calculate the percentage contribution of each pizza type to total revenue.

WITH pizza_revenue AS
(
    SELECT
        pizza_types.name,
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM pizza_types
    INNER JOIN pizzas
        ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    INNER JOIN order_details
        ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.name
)

SELECT
    name,
    revenue,
    ROUND(
        (revenue * 100.0 / SUM(revenue) OVER()), 2
    ) AS revenue_percentage
FROM pizza_revenue
ORDER BY revenue_percentage DESC



--Analyze the cumulative revenue generated over time.


WITH sales AS
(
    SELECT
        orders.date,
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details
    INNER JOIN pizzas
        ON order_details.pizza_id = pizzas.pizza_id
    INNER JOIN orders
        ON orders.order_id = order_details.order_id
    GROUP BY orders.date
)
SELECT
    date,
    revenue,
    SUM(revenue) OVER (
        ORDER BY date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cum_revenue
FROM sales
ORDER BY date



--Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH pizza_revenue AS
(
    SELECT
        pizza_types.category,
        pizza_types.name,
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM pizza_types
    INNER JOIN pizzas
        ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    INNER JOIN order_details
        ON pizzas.pizza_id = order_details.pizza_id
    GROUP BY
        pizza_types.category,
        pizza_types.name
),

ranked_pizzas AS
(
    SELECT
        category,
        name,
        revenue,
        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS pizza_rank
    FROM pizza_revenue
)

SELECT
    category,
    name,
    revenue,
    pizza_rank
FROM ranked_pizzas
WHERE pizza_rank <= 3
ORDER BY category, pizza_rank;





 


















