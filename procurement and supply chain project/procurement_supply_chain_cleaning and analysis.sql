create database supply_chain;

use supply_chain;

select *
from data;

create table data_clean as
select *
from data;

select *
from data_clean;


select count(*)
from data_clean;   -- we have 839 total rows
 
 select count(distinct PO_ID) as uniqe_po_id_count
 from data_clean;                              -- we have total 777 uniqe po_id
 
 select count( distinct supplier_id) as uniqe_supplier_id_count
 from data_clean;                 --  we have total 777 uniqe supplier_id
 
 select Compliance,upper(Compliance) as Compliance_clean
 from data_clean;
 
 begin;
 
 update data_clean
 set Compliance = upper(Compliance);
 
 commit;
 
 begin;
 
 
 select distinct Order_Status
 from data_clean;
 
 select distinct risk_flag
 from data_clean;
 
 UPDATE data_clean
SET Order_Date =
CASE
    WHEN Order_Date LIKE '%.%' THEN
        DATE_FORMAT(STR_TO_DATE(Order_Date, '%d.%m.%y'), '%Y-%m-%d')
    WHEN Order_Date LIKE '%-%' THEN
        DATE_FORMAT(STR_TO_DATE(Order_Date, '%d-%m-%Y'), '%Y-%m-%d')
    ELSE Order_Date
END;

select Order_Date,Delivery_Date 
from data_clean;

UPDATE data_clean
SET Delivery_Date =
CASE
    WHEN Delivery_Date LIKE '%.%' THEN
        DATE_FORMAT(STR_TO_DATE(Delivery_Date, '%d.%m.%y'), '%Y-%m-%d')
    WHEN Delivery_Date LIKE '%-%' THEN
        DATE_FORMAT(STR_TO_DATE(Delivery_Date, '%d-%m-%Y'), '%Y-%m-%d')
    ELSE Delivery_Date
END;

select *
from data_clean;

SELECT
PO_ID,supplier_id,supplier_name,supplier_country,supplier_city,Order_Date,Delivery_Date,
Item_Category,Order_Status,Quantity,Unit_Price,Negotiated_Price,Defective_Units,Compliance,risk_flag,requestor_department,
COUNT(*) AS duplicate_count
FROM data_clean
GROUP BY PO_ID,supplier_id,supplier_name,supplier_country,supplier_city,Order_Date,
Delivery_Date,Item_Category,Order_Status,Quantity,Unit_Price,
Negotiated_Price,Defective_Units,Compliance,risk_flag,requestor_department
HAVING COUNT(*) > 1;

SELECT PO_ID, COUNT(*)
FROM data_clean
GROUP BY PO_ID
HAVING COUNT(*) > 1;

SELECT * ,row_number() over(partition by
PO_ID,supplier_id,supplier_name,supplier_country,supplier_city,Order_Date,Delivery_Date,
Item_Category,Order_Status,Quantity,Unit_Price,Negotiated_Price,Defective_Units,Compliance,risk_flag,requestor_department order by PO_ID) as duplicate_count
from data_clean;

with duplicates as (SELECT * ,row_number() over(partition by
PO_ID,supplier_id,supplier_name,supplier_country,supplier_city,Order_Date,Delivery_Date,
Item_Category,Order_Status,Quantity,Unit_Price,Negotiated_Price,Defective_Units,Compliance,risk_flag,requestor_department order by PO_ID) as duplicate_count
from data_clean)

select count(*) 
from data_clean;

describe data_clean;

alter table data_clean
add column id int auto_increment
primary key;

DELETE d
FROM data_clean d
JOIN (SELECT id,ROW_NUMBER() OVER (PARTITION BY PO_ID,supplier_id,supplier_name,supplier_country,supplier_city,Order_Date,
Delivery_Date,Item_Category,Order_Status,Quantity,Unit_Price,Negotiated_Price,Defective_Units,Compliance,risk_flag,requestor_department
ORDER BY id) AS rn
FROM data_clean) t
ON d.id = t.id
WHERE t.rn > 1; -- 62 rows deleted 

select count(*) as null_order_date
from data_clean
where Delivery_Date is null;

select *
from data_clean;

select count(*) as blank_Delivery_Date
from data_clean
where Delivery_Date is null
or trim(Delivery_Date) = '';

select count(*) as blank_Defective_Units
from data_clean
where Defective_Units is null
or trim(Defective_Units) = '';

select *,row_number() over()
from data_clean
where Delivery_Date is null
or trim(Delivery_Date) = '';

select *,row_number() over()
from data_clean
where Defective_Units is null
or trim(Defective_Units) = '';


update data_clean
set Defective_Units = 0
where Defective_Units is null
or trim(Defective_Units) = '';

select Order_Status, count(*) 
from data_clean
where Delivery_Date is null
or trim(Delivery_Date) = ''
group by Order_Status;

SELECT *
FROM data_clean
WHERE Order_Status = 'Delivered'
  AND (Delivery_Date IS NULL OR TRIM(Delivery_Date) = '');   -- we are goint to keep Delivery_Date as blank cause there is no reliable business rule 
                                                             -- or additional information to infer the correct dates, we retained them as
                                                             --   NULL and documented them as a data quality issue
  

 select count(*)
from data_clean;

commit;


select * 
from data_clean;
  
SELECT supplier_id , COUNT(*)
FROM data_clean
GROUP BY supplier_id
HAVING COUNT(*) > 1;

describe data_clean;

SELECT *
FROM data_clean
WHERE Delivery_Date = '';


update data_clean
set Delivery_Date = null
WHERE Delivery_Date = '';

select PO_ID
from data_clean
where Delivery_Date is null ;

ALTER TABLE data_clean
MODIFY PO_ID VARCHAR(20),
MODIFY supplier_id VARCHAR(20),
MODIFY supplier_name VARCHAR(150),
MODIFY supplier_country VARCHAR(50),
MODIFY supplier_city VARCHAR(50),
MODIFY Order_Date DATE,
MODIFY Delivery_Date DATE,
MODIFY Item_Category VARCHAR(50),
MODIFY Order_Status VARCHAR(30),
MODIFY Unit_Price DECIMAL(10,2),
MODIFY Negotiated_Price DECIMAL(10,2),
MODIFY Defective_Units INT,
MODIFY Compliance VARCHAR(5),
MODIFY risk_flag VARCHAR(20),
MODIFY requestor_department VARCHAR(50);

ALTER TABLE  data_clean
modify id int;

alter table data_clean
drop primary key;

alter table data_clean
add primary key (PO_ID);

describe
data_clean;

alter table data_clean
drop id ;

select *
from data_clean;

use supply_chain;

select count(distinct PO_ID)
from data_clean; -- 777 unique po_id

select sum(Quantity * Negotiated_Price) as total_procurement_spend
from data_clean;

select avg(po_value) as avrage_po_value
from ( select po_id, sum(quantity * Negotiated_Price) as po_value
from data_clean
group by po_id) as po_summry; 

select max(po_value) as higest_purchase_value
from ( select po_id ,sum(quantity * Negotiated_Price) as po_value
from data_clean
group by po_id) as po_summry;-- without using offset/ limit
 
 select po_value as higest_purchase_value
from ( select po_id ,sum(quantity * Negotiated_Price) as po_value
from data_clean
group by po_id) as po_summry
order by po_value desc
limit 1; -- by using limit 

select min(po_value) as lowest_purchase_value
from ( select po_id ,sum(quantity * Negotiated_Price) as po_value
from data_clean
group by po_id) as po_summry;-- without using offset/ limit

select po_value as lowest_purchase_value
from ( select po_id ,sum(quantity * Negotiated_Price) as po_value
from data_clean
group by po_id) as po_summry
order by po_value asc
limit 1 ;-- by using limit 

select sum(Quantity)
from data_clean;

select po_id,
sum(quantity * Negotiated_Price) as total_spend
from data_clean
group by po_id;

select po_id,
sum(quantity * Negotiated_Price) as total_spend
from data_clean
group by po_id
order by total_spend desc
limit 10;

select po_id,quantity
from data_clean
group by po_id;

select supplier_id,avg(Negotiated_Price)
from data_clean
group by supplier_id;


select *
from data_clean ;

select*,datediff(Delivery_Date,Order_Date)
from data_clean;

select supplier_id,
avg(datediff(Delivery_Date,Order_Date)) as avrage_lead_time
from data_clean
group by supplier_id;

select supplier_id,
avg(datediff(Delivery_Date,Order_Date)) as avrage_lead_time
from data_clean
group by supplier_id
order by  avrage_lead_time desc;

select count(po_id),supplier_id
from data_clean
group by supplier_id;


select count(po_id),supplier_id
from data_clean
group by supplier_id
having count(po_id) > 1;


select Item_Category ,sum(quantity * Negotiated_Price) as total_spend
from data_clean 
group by Item_Category;

select Item_Category ,sum(quantity * Negotiated_Price) as total_spend
from data_clean 
group by Item_Category
order by total_spend desc
limit 1;

select Item_Category ,sum(quantity) as total_quantitty
from data_clean 
group by Item_Category;

select  Item_Category,avg (Negotiated_Price) as avg_unite_price
from  data_clean
group by  Item_Category;

use supply_chain;

select *
from data_clean ;

select requestor_department,sum(quantity * Negotiated_Price) as  total_spend
from data_clean
group by requestor_department;


select requestor_department,sum(quantity * Negotiated_Price) as  total_spend
from data_clean
group by requestor_department
order by total_spend desc
limit 1;

select count(po_id),requestor_department
from data_clean
group by requestor_department;

select supplier_country,sum(quantity * Negotiated_Price) as total_spend
from data_clean
group by supplier_country;

select supplier_country,sum(quantity * Negotiated_Price) as total_spend
from data_clean
group by supplier_country
order by total_spend desc
limit 1;

select supplier_country, avg(datediff(Delivery_Date,Order_Date)) as avg_lead_time 
from data_clean
group by supplier_country;

select supplier_country, avg(datediff(Delivery_Date,Order_Date)) as avg_lead_time 
from data_clean
group by po_id;

select *
from data_clean ;

select po_id,supplier_id,(Unit_Price - Negotiated_Price)*Quantity as total_saving
from data_clean;

select po_id,supplier_id,(Unit_Price - Negotiated_Price)*Quantity as total_saving
from data_clean
order by total_saving desc
limit 1;

select supplier_id,sum((Unit_Price - Negotiated_Price)*quantity)as avg_saving
from data_clean
group by supplier_id;


select supplier_id,sum((Unit_Price - Negotiated_Price)*quantity)as avg_saving
from data_clean
group by supplier_id
order by avg_saving desc
limit 1;

SELECT supplier_id,supplier_name,risk_flag,
CASE WHEN risk_flag = 'Low' THEN 'Low Risk'
WHEN risk_flag = 'Medium' THEN 'Medium Risk'
WHEN risk_flag = 'High' THEN 'High Risk'
ELSE 'Unknown'
END AS Risk_Category
FROM data_clean;

use supply_chain;

select *
from data_clean;

select supplier_id,sum( Quantity * Negotiated_Price) as total_spend,
rank() over( order by sum(Quantity * Negotiated_Price) desc) as supplier_rank
from data_clean
group by supplier_id
order by supplier_rank;

select supplier_id,sum((Unit_Price - Negotiated_Price )*Quantity) as total_saved,
rank() over( order by( sum((Unit_Price- Negotiated_Price )*Quantity)) desc) as supplier_rank
from data_clean
group by supplier_id
order by supplier_rank;

select Item_Category, supplier_id,sum( Quantity * Negotiated_Price) as total_spend,
rank() over ( partition by Item_Category  order by sum(Quantity * Negotiated_Price) desc) as supplier_rank
from data_clean
group by Item_Category,supplier_id
order by supplier_rank,Item_Category;

SELECT
    supplier_id,
    supplier_name,
    SUM(Quantity * Negotiated_Price) AS total_spend
FROM data_clean
GROUP BY supplier_id, supplier_name
ORDER BY total_spend DESC
LIMIT 3;

WITH supplier_spend AS (SELECT supplier_id,supplier_name,
SUM(Quantity * Negotiated_Price) AS total_spend
FROM data_clean
GROUP BY supplier_id, supplier_name)
SELECT
supplier_id,
supplier_name,
total_spend,
ROUND(total_spend * 100.0 / SUM(total_spend) OVER (),2) AS spend_percentage
FROM supplier_spend
ORDER BY total_spend DESC;

WITH daily_spend AS (SELECT Order_Date,
SUM(Quantity * Negotiated_Price) AS daily_spend
FROM data_clean GROUP BY Order_Date)
SELECT
Order_Date,daily_spend,SUM(daily_spend)
OVER(ORDER BY Order_Date) AS running_total
FROM daily_spend
ORDER BY Order_Date;

WITH supplier_metrics AS (SELECT supplier_id,
SUM(Quantity * Negotiated_Price) AS total_spend,
SUM(Defective_Units) * 100.0 / SUM(Quantity) AS defect_rate
FROM data_clean
GROUP BY supplier_id)
SELECT supplier_id,
total_spend,
defect_rate
FROM supplier_metrics
WHERE total_spend > (SELECT AVG(total_spend)
FROM supplier_metrics)
AND defect_rate > (SELECT AVG(defect_rate)
FROM supplier_metrics)ORDER BY total_spend DESC;

WITH supplier_metrics AS (SELECT
supplier_id,
SUM(Quantity * Negotiated_Price) AS total_spend,
SUM(Defective_Units) * 100.0 / SUM(Quantity) AS defect_rate,
MAX(risk_flag) AS risk_flag
FROM data_clean
GROUP BY supplier_id)
SELECT supplier_id,
total_spend,
defect_rate,
risk_flag
FROM supplier_metrics
WHERE total_spend > (SELECT AVG(total_spend)
FROM supplier_metrics)
AND defect_rate >(SELECT AVG(defect_rate)
FROM supplier_metrics)
AND risk_flag = 'High'
ORDER BY total_spend DESC;

create view procurement_analysis as
select *
from data_clean;

select * 
from procurement_analysis;