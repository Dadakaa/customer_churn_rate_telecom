-- Ознакомление с датасетом:
select *
from telecom
limit 5

-- Кол-во строк в датасете:
select count(*) as total_rows
from telecom

-- Есть ли дубликаты:
select
    customer_id,
    count(*) as duplicates_count
from telecom
group by customer_id
having count(*) > 1

-- Проверка NULL и пустых значений:
select *
from telecom
where monthly_charges is null
	or (total_charges is null and tenure != 0)
	or monthly_charges < 0
	or total_charges < 0
	
	
-- Распределение клиентов по churn:
select
    churn,
    count(*) customers,
    round(count(*) * 100.0 / sum(count(*)) over(), 2) percent_customers
from telecom
group by churn


-- Анализ влияния параметров на churn:

with all_churn_rate as(
	select
		'tenure' parametr,
		case
			when tenure <= 6 then '0-6 months'
			when tenure <= 24 then '7-24 months'
			when tenure <= 48 then '25-48 months'
			else '48+ months'
		end as segment,
		round(avg(case when churn = 'Yes' then 1 else 0 end), 2) churn_rate
	from telecom 
	group by segment
	
	union all
	
/* Значения, которые подставим в case под monthly_charges
 select
    min(monthly_charges),
    percentile_cont(0.25) within group (order by monthly_charges),
    percentile_cont(0.5) within group (order by monthly_charges),
    percentile_cont(0.75) within group (order by monthly_charges),
    max(monthly_charges)
from telecom */

	select
		'monthly_charges' parametr,
		case 
			when monthly_charges < 35.5 then '< 35.5 (low)'
			when monthly_charges < 70.35 then '< 70.35 (medium)'
			else '> 70.35 (high)'
		end segment,
		round(avg(case when churn = 'Yes' then 1 else 0 end), 2) churn_rate
		from telecom
		group by segment
	
	union all
	
	select 
		'internet_service' parametr,
		internet_service as segment,
		round(avg(case when churn = 'Yes' then 1 else 0 end), 2) churn_rate
	from telecom
	group by segment
	
	union all
	
	select 
		'online_backup' parametr,
		online_backup as segment,
		round(avg(case when churn = 'Yes' then 1 else 0 end), 2) churn_rate
	from telecom
	group by segment
	
	union all
	
	select 
		'tech_support' parametr,
		tech_support as segment,
		round(avg(case when churn = 'Yes' then 1 else 0 end), 2) churn_rate
	from telecom
	group by segment
	
	union all
	
	select 
		'streaming_tv' parametr,
		streaming_tv as segment,
		round(avg(case when churn = 'Yes' then 1 else 0 end), 2) churn_rate
	from telecom
	group by segment
	
	
	union all
	
	select 
		'contract' parametr,
		contract as segment,
		round(avg(case when churn = 'Yes' then 1 else 0 end), 2) churn_rate
	from telecom
	group by segment
), general_churn_rate as(
	select
		round(avg(case when churn = 'Yes' then 1 else 0 end), 2) general_churn_rate
	from telecom
)
select 
	acr.*,
	gcr.general_churn_rate,
	round(acr.churn_rate - gcr.general_churn_rate, 2) as churn_diff
from all_churn_rate acr
cross join general_churn_rate gcr
order by churn_rate desc


