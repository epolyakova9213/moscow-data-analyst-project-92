SELECT 
    CONCAT(e.first_name, ' ', e.middle_initial, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) as operations,
    SUM(s.quantity) as income
FROM employees e 
INNER JOIN sales s ON e.employee_id = s.sales_person_id  
GROUP BY e.first_name, e.middle_initial, e.last_name    
ORDER BY income DESC
LIMIT 10;
--отчет о десятке лучших продавцов