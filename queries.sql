select COUNT(customer_id) as customers_count  --COUNT(customer_id) считает количество покупателей а AS присваивает этому столбцу алеас 
from customers --данные берем из таблицы customers

select 
	CONCAT(e.first_name, ' ', e.last_name) as seller, --объединяем имя и фамилию через пробел и присваиваем алеас 
	COUNT(s.sales_id) as operations, --считаем  количество сделок и присваиваем алеас 
	FLOOR(SUM(p.price * s.quantity)) as income --считаем выручку и округляем в меньшую сторону и присваиваем алеас 
from sales as s --берем за основу таблицу 
join employees as e --присоединяем дополнительные таблицы 
	on s.sales_person_id = e.employee_id 
join products as p 
	on s.product_id = p.product_id
group by e.first_name, e.last_name --группируем 
order by FLOOR(SUM(p.price * s.quantity)) desc --сортируем 
limit 10 --получаем только 10 записей 

with table_1 as (select 
	AVG(p.price * s.quantity) as vse_prod  --объявили CTE в котором нашли среднюю выручку по всем продавцам 
from sales as s --берем за основу таблицу
join products as p 
	on s.product_id = p.product_id ) --присоединяем дополнительную  таблицу 
select 
	CONCAT(e.first_name, ' ', e.last_name) as seller, --объединяем имя и фамилию через пробел и присваиваем алеас 
	FLOOR(AVG(p.price * s.quantity)) as average_income --считаем среднюю выручку по каждому продацу  с округлением в меньшую сторону 
from sales as s --берем за основу таблицу 
join products as p 
	on s.product_id = p.product_id 
join employees as e 
	on s.sales_person_id = e.employee_id 
cross join table_1 --присоединяем дополнительные таблицы и наш CTE 
group by e.first_name, e.last_name, table_1.vse_prod --группируем 
having (AVG(p.price * s.quantity)) < table_1.vse_prod --объявляем условие 
order by average_income asc --сортируем 

select 
	concat(e.first_name, ' ', e.last_name) as seller, --объединяем имя и фамилию через пробел и присваиваем алеас 
	to_char(s.sale_date, 'FMday') as day_of_week, --достаем название дня недели из даты 
	FLOOR(SUM(p.price * s.quantity)) as income --находим среднюю выручку по каждому продавцу 
from sales as s --берем за основу таблицу 
join products as p 
	on s.product_id = p.product_id 
join employees as e 
	on s.sales_person_id = e.employee_id --присоединяем дополнительные таблицы 
group by e.first_name, e.last_name, to_char(s.sale_date, 'FMday'), EXTRACT(DOW FROM s.sale_date) --группируем  по имени фамилии дню недели и порядковому номеру дня недели 
order by CASE
        WHEN EXTRACT(DOW FROM s.sale_date) = 0 THEN 7
        ELSE EXTRACT(DOW FROM s.sale_date)
    END,
    seller --сортируем по продавцу порядковому дню недели заменяя порядковый номер 0 на 7 чтобы воскресенье было седьмым днем 