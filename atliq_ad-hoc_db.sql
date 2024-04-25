/*/////////////////////////////////AD HOC*/
select distinct(market) from dim_customer
where region = 'APAC'
and customer = 'Atliq Exclusive'


/*req1*/
select COUNT(DISTINCT case when fiscal_year =2020 then product_code end) as unique_product_2020, 
COUNT(DISTINCT case when fiscal_year =2021 then product_code end) as unique_product_2021 from fact_sales_monthly


/*req2*/
with percentage_chg as (select COUNT(DISTINCT case when fiscal_year =2020 then product_code end) as unique_product_2020, 
COUNT(DISTINCT case when fiscal_year =2021 then product_code end) as unique_product_2021 from fact_sales_monthly)
select unique_product_2020, unique_product_2021, round(((unique_product_2021-unique_product_2020)/unique_product_2020)*100,2) as percentage_change from percentage_chg


/*req3*/
select segment, count(distinct case when product_code)) as product_count from dim_product
group by segment
order by product_count DESC


/*req4*/
with differ as (select dp.segment, COUNT(DISTINCT (case when fiscal_year =2020 then fsm.product_code end)) as product_count_2020, 
COUNT(DISTINCT (case when fiscal_year =2021 then fsm.product_code end)) as product_count_2021 from fact_sales_monthly as fsm
inner join dim_product as dp
on dp.product_code = fsm.product_code 
group by dp.segment)
select segment, product_count_2020, product_count_2021, ROUND(product_count_2021-product_count_2020) as Difference from differ
order by Difference DESC


/*req5*/
select dp.product_code, product, fmc.manufacturing_cost from dim_product as dp
join fact_manufacturing_cost as fmc
on dp.product_code = fmc.product_code
where fmc.manufacturing_cost = (select max(manufacturing_cost) from fact_manufacturing_cost)
or fmc.manufacturing_cost = (select min(manufacturing_cost) from fact_manufacturing_cost)
order by fmc.manufacturing_cost desc


/*req6*/
select dc.customer_code, customer, round(avg(fpid.pre_invoice_discount_pct)*100) as average_discount_percentage  from dim_customer as dc
join fact_pre_invoice_deductions as fpid
on dc.customer_code = fpid.customer_code
where market = 'India' and fiscal_year = 2021
group by customer_code, customer
order by average_discount_percentage DESC
limit 5

/*req7*/
select  monthname(fsm.date) as month_name, year(date) as year_, ROUND(SUM(fsm.sold_quantity * fgp.gross_price)/1000000,2) as gross_sales_amount from fact_sales_monthly as fsm
inner Join dim_customer as dc
on dc.customer_code = fsm.customer_code
inner join fact_gross_price as fgp
on fgp.product_code = fsm.product_code
and fgp.fiscal_year = fsm.fiscal_year
where customer = "Atliq Exclusive"
group by date
order by date

/*req8*/
select case when month(date) in (9,10,11) then 'Q1'
when month(date) in (12,1,2) then 'Q2'
when month(date) in (3,4,5) then 'Q3'
else 'Q4' 
end as quarters, sum(sold_quantity) as total_sold_quantity from fact_sales_monthly
where fiscal_year = 2020
group by quarters
order by total_sold_quantity desc

/*re8a*/
select case when month(date) in (9,10,11) then 'Q1'
when month(date) in (12,1,2) then 'Q2'
when month(date) in (3,4,5) then 'Q3'
else 'Q4' 
end as quarters, monthname(date) as month_, sum(sold_quantity) as total_sold_quantity from fact_sales_monthly
where fiscal_year = 2020
group by quarters, month_
order by quarters and total_sold_quantity desc

/*req8b*/
 

/*req9*/
with percent as (select channel as chanel, ROUND(SUM(fsm.sold_quantity * fgp.gross_price)/1000000) as g_s_m from fact_sales_monthly as fsm
inner Join dim_customer as dc
on dc.customer_code = fsm.customer_code
inner join fact_gross_price as fgp
on fgp.product_code = fsm.product_code
and fgp.fiscal_year = fsm.fiscal_year
where fgp.fiscal_year = 2021
group by channel)
select chanel, SUM(g_s_m) as gross_sales_in_millions, (g_s_m/sum(g_s_m)over()*100) as percentage from percent
group by chanel
order by gross_sales_in_millions desc

/*req10*/
With rank_ as
(
SELECT dp.division AS division,
dp.product_code AS product_code,
dp.product AS product,
SUM(fsm.sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly AS fsm
INNER JOIN dim_product AS dp
ON fsm.product_code = dp.product_code
WHERE fsm.fiscal_year = 2021
GROUP BY dp.division, dp.product_code, dp.product
ORDER BY total_sold_quantity DESC
),
top_division As
(SELECT division,
product_code,
product,
total_sold_quantity,
RANK () OVER (PARTITION BY division ORDER BY total_sold_quantity DESC)
AS rank_order
FROM rank_
)
SELECT * FROM top_division
WHERE rank_order <= 3;