SELECT
    COUNT(customer_id) AS customers_count
FROM customers;
/*запрос выбирает и подсчитывает количество покупателей из таблицы покупателей,
отображая результат в новом столбце customers_count*/

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    SUM(s.quantity) AS income
FROM employees AS e
INNER JOIN sales AS s ON e.employee_id = s.sales_person_id
GROUP BY e.first_name, e.last_name
ORDER BY income ASC
LIMIT 10;
--отчет о десятке лучших продавцов

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(AVG(s.quantity * p.price)) AS average_income
FROM employees AS e
LEFT JOIN sales AS s ON e.employee_id = s.sales_person_id
LEFT JOIN products AS p ON s.product_id = p.product_id
GROUP BY seller
HAVING
    AVG(s.quantity * p.price) < (
        SELECT AVG(s2.quantity * p2.price)
        FROM sales AS s2
        LEFT JOIN products AS p2 ON s2.product_id = p2.product_id
    )
ORDER BY average_income ASC NULLS LAST;
/*отчет о продавцах, чья средняя выручка за сделку
меньше средней выручки за сделку по всем продавцам*/

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    LOWER(TO_CHAR(s.sale_date, 'FMDay')) AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM employees AS e
INNER JOIN sales AS s ON e.employee_id = s.sales_person_id
INNER JOIN products AS p ON s.product_id = p.product_id
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
    END AS age_category,
    COUNT(*) AS age_count
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

SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    ROUND(SUM(s.quantity * p.price), 0) AS income
FROM sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY TO_CHAR(s.sale_date, 'YYYY-MM') ASC;
--отчет показывает кол-во уникальных покупателей и выручку в месяц года

WITH first_purchases AS (
    SELECT
        s.customer_id,
        p.product_id,
        p.price,
        MIN(s.sale_date) AS first_sale_date
    FROM products AS p
    LEFT JOIN sales AS s ON p.product_id = s.product_id
    WHERE
        p.price = 0
        AND s.customer_id IS NOT NULL
    GROUP BY s.customer_id, p.product_id
)

SELECT DISTINCT ON (c.customer_id)
    fp.first_sale_date AS sale_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM first_purchases AS fp
INNER JOIN sales AS s
    ON
        fp.customer_id = s.customer_id
        AND fp.first_sale_date = s.sale_date
INNER JOIN customers AS c ON fp.customer_id = c.customer_id
INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
ORDER BY c.customer_id;
/*выбирает в CTE покупателей с первой покупкой товара с ценой 0
потом в основном запросе уже джойнит из таблиц нужные поля, но с условием уникальности по customer_id,
потому что покупатели в свой первый день делали по нескольк покупок товаров с ценой 0*/
