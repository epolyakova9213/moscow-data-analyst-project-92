SELECT COUNT(customer_id) AS customers_count
FROM customers;
/*запрос выбирает и подсчитывает количество покупателей из таблицы покупателей,
отображая результат в новом столбце customers_count*/

select 
concat (e.first_name, ' ', e.middle_initial, ' ', e.last_name) AS seller,
count (s.sales_id) as operations,
sum (s.quantity) as income
from employees e 
left join sales s on e.employee_id=s.sales_person_id
group by seller
order by income desc nulls last
limit 10;
--отчет о десятке лучших продавцов

select 
concat (e.first_name, ' ', e.middle_initial, ' ', e.last_name) AS seller,
FLOOR(AVG(s.quantity)) as  average_income
from employees e 
left join sales s on e.employee_id=s.sales_person_id
group by seller
having avg (s.quantity)>(select avg (quantity) from sales)
order by average_income asc nulls last;
*/отчет о продавцах, чья средняя выручка за сделку 
меньше средней выручки за сделку по всем продавцам/*

SELECT 
    CONCAT(e.first_name, ' ', e.middle_initial, ' ', e.last_name) AS seller,
    TO_CHAR(s.sale_date, 'FMDay') as day_of_week,
    FLOOR(SUM(s.quantity)) as income
FROM employees e 
FULL JOIN sales s ON e.employee_id = s.sales_person_id
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
    END;
*/запрос выводит ФИО продавца и его выручку за день 
 по дням недели с сортировкой по хронологии недели/*
