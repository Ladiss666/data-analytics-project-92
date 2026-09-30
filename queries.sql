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

	select 
case 
	when c.age between 16 and 25 then '16-25' --данный запрос делдит покупателей по возрастным группам и считает сколько покупателей в каждой грппе
	when c.age between 26 and 40 then '26-40'
	when c.age > 40 then '40+'
end as age_category,
	count(c.age) as age_count
from customers as c 
group by age_category 
order by age_category

select --данный запррос показывает сколько уникальных покупателей какую выручку принесли в каждом месяце 
	to_char(s.sale_date, 'YYYY-MM') as selling_month,
	count(distinct(c.customer_id)) as total_customers,
	FLOOR(sum(s.quantity * p.price )) as income
from sales as s
join products as p 
	on s.product_id = p.product_id
join customers as c 
	on s.customer_id = c.customer_id
group by selling_month 
order by selling_month

with table_1 as (select s.sales_id, --данный запрос показывает покупателей первая покупка которых была совершена в момент проведения акции
					    s.customer_id,
					    s.sales_person_id,
					    s.sale_date,
					    p.price,
					    row_number() over (partition by s.customer_id order by s.sale_date, s.sales_id
					    ) as row_number
					from sales as s
					join products as p
					    on s.product_id = p.product_id)
select
    concat(c.first_name, ' ', c.last_name) as customer,
    t.sale_date as sale_date,
    concat(e.first_name, ' ', e.last_name) as seller
from table_1 as t 
join customers as c
    on t.customer_id = c.customer_id
join employees as e
    on t.sales_person_id = e.employee_id
where t.row_number = 1
  and t.price = 0
order by c.customer_id