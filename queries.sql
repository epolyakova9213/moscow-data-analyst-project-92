SELECT COUNT(customer_id) AS customers_count
FROM customers;
/*запрос выбирает и подсчитывает количество покупателей из таблицы покупателей,
отображая результат в новом столбце customers_count*/

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) as operations,
    SUM(s.quantity) as income
FROM employees e 
INNER JOIN sales s ON e.employee_id = s.sales_person_id  
GROUP BY e.first_name, e.middle_initial, e.last_name    
ORDER BY income ASC
LIMIT 10;
--отчет о десятке лучших продавцов

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(AVG(s.quantity * p.price)) as average_income
FROM employees e 
LEFT JOIN sales s ON e.employee_id = s.sales_person_id
LEFT JOIN products p ON s.product_id = p.product_id
GROUP BY seller
HAVING AVG(s.quantity * p.price) < (
    SELECT AVG(s2.quantity * p2.price) 
    FROM sales s2 
    LEFT JOIN products p2 ON s2.product_id = p2.product_id
)
ORDER BY average_income ASC NULLS LAST;
/*отчет о продавцах, чья средняя выручка за сделку 
меньше средней выручки за сделку по всем продавцам*/

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    LOWER(TO_CHAR(s.sale_date, 'FMDay')) as day_of_week,
    FLOOR(SUM(s.quantity * p.price)) as income
FROM employees e 
INNER JOIN sales s ON e.employee_id = s.sales_person_id
INNER JOIN products p ON s.product_id = p.product_id
WHERE s.sale_date IS NOT NULL
GROUP BY 
    e.first_name, 
    e.middle_initial, 
    e.last_name,
    TO_CHAR(s.sale_date, 'FMDay')
ORDER BY 
    CASE 
        WHEN TO_CHAR(s.sale_date, 'FMDay') = 'Monday' THEN 1
        WHEN TO_CHAR(s.sale_date, 'FMDay') = 'Tuesday' THEN 2
        WHEN TO_CHAR(s.sale_date, 'FMDay') = 'Wednesday' THEN 3
        WHEN TO_CHAR(s.sale_date, 'FMDay') = 'Thursday' THEN 4
        WHEN TO_CHAR(s.sale_date, 'FMDay') = 'Friday' THEN 5
        WHEN TO_CHAR(s.sale_date, 'FMDay') = 'Saturday' THEN 6
        WHEN TO_CHAR(s.sale_date, 'FMDay') = 'Sunday' THEN 7
    END,
    seller;
/*запрос выводит ФИО продавца и его выручку за день 
 по дням недели с сортировкой по хронологии недели*/

SELECT 
    CASE 
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        WHEN age > 40 THEN '40+'
        ELSE 'Другие'
    END as age_category,
    COUNT(*) as age_count
FROM customers
GROUP BY 
    CASE 
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        WHEN age > 40 THEN '40+'
        ELSE 'Другие'
    END
ORDER BY age_category;
--отчет сегментирует клиентов на категории по возрасту с подсчетом кол-ва клиентов

select
to_char(sale_date, 'YYYY-MM') as selling_month,
count(distinct customer_id) as total_customers,
sum (quantity) as income
from sales s 
group by to_char(sale_date, 'YYYY-MM')
order by to_char(sale_date, 'YYYY-MM') asc;
--отчет показывает кол-во уникальных покупателей и выручку в месяц года

with first_purchases as (
select 
s.customer_id,
min(sale_date) as first_sale_date,
p.product_id,
p.price
from products p
left join sales s on p.product_id=s.product_id
where p.price=0
and customer_id is not null
group by customer_id, p.product_id
)
select distinct on (c.customer_id)
concat(c.first_name,' ',c.last_name) as customer,
fp.first_sale_date as sale_date,
concat(e.first_name,' ',e.last_name) as seller
from first_purchases fp
join sales s on fp.customer_id=s.customer_id 
            and fp.first_sale_date=s.sale_date
join customers c on fp.customer_id=c.customer_id
join employees e on s.sales_person_id=e.employee_id 
order by c.customer_id;
/*выбирает в CTE покупателей с первой покупкой товара с ценой 0
потом в основном запросе уже джойнит из таблиц нужные поля, но с условием уникальности по customer_id,
потому что покупатели в свой первый день делали по нескольк покупок товаров с ценой 0*/
