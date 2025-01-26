
--DROP TABLE PRANALI_ASSESSMENT_22JAN2025;

--Total Count
SELECT 
COUNT(*)
FROM PRANALI_ASSESSMENT_22JAN2025;
--500000

--No of records missing from data
select
 count(case when TransactionID     = '' then TransactionID    end) MISSING_TransactionID    
,count(case when CustomerID		   = '' then CustomerID		  end) MISSING_CustomerID		  
,count(case when TransactionDate   = '' then TransactionDate  end) MISSING_TransactionDate  
,count(case when TransactionAmount = '' then TransactionAmount end) MISSING_TransactionAmount
,count(case when PaymentMethod	   = '' then PaymentMethod	  end) MISSING_PaymentMethod	  
,count(case when Quantity		   = '' then Quantity		  end) MISSING_Quantity		  
,count(case when DiscountPercent   = '' then DiscountPercent  end) MISSING_DiscountPercent  
,count(case when City			   = '' then City			  end) MISSING_City			  
,count(case when StoreType		   = '' then StoreType		  end) MISSING_StoreType		  
,count(case when CustomerAge	   = '' then CustomerAge	  end) MISSING_CustomerAge	  
,count(case when CustomerGender	   = '' then CustomerGender	  end) MISSING_CustomerGender	  
,count(case when LoyaltyPoints	   = '' then LoyaltyPoints	  end) MISSING_LoyaltyPoints	  
,count(case when ProductName	   = '' then ProductName	  end) MISSING_ProductName	  
,count(case when Region			   = '' then Region			  end) MISSING_Region			  
,count(case when Returned		   = '' then Returned		  end) MISSING_Returned		  
,count(case when FeedbackScore	   = '' then FeedbackScore	  end) MISSING_FeedbackScore	  
,count(case when ShippingCost	   = '' then ShippingCost	  end) MISSING_ShippingCost	  
,count(case when DeliveryTimeDays  = '' then DeliveryTimeDays end) MISSING_DeliveryTimeDays 
,count(case when IsPromotional	   = '' then IsPromotional	  end) MISSING_IsPromotional	  
FROM PRANALI_ASSESSMENT_22JAN2025;

--Total Distinct Entries
SELECT DISTINCT *
FROM PRANALI_ASSESSMENT_22JAN2025;
--500000

--Total transactions and total distinct transid
SELECT COUNT(*),COUNT(TRANSACTIONID),COUNT(DISTINCT TRANSACTIONID)
FROM PRANALI_ASSESSMENT_22JAN2025;
--500000	500000	500000

--Total ditinct customers
SELECT COUNT(*),COUNT(CUSTOMERID),COUNT(DISTINCT CUSTOMERID)
FROM PRANALI_ASSESSMENT_22JAN2025;
--500000	500000	48995

--Cleaning Custids
SELECT COUNT(*)
FROM PRANALI_ASSESSMENT_22JAN2025
WHERE CUSTOMERID = '';
--50000

UPDATE PRANALI_ASSESSMENT_22JAN2025
SET CUSTOMERID = NULL
WHERE CUSTOMERID = '';
--50000

--Total ditinct customers
SELECT COUNT(*),COUNT(CUSTOMERID),COUNT(DISTINCT CUSTOMERID)
FROM PRANALI_ASSESSMENT_22JAN2025;
--500000	450000	48994

--Convert Tran_date to datetime
SELECT TRANSACTIONDATE,CONVERT(DATETIME,TRANSACTIONDATE,105)
FROM PRANALI_ASSESSMENT_22JAN2025

ALTER TABLE PRANALI_ASSESSMENT_22JAN2025
ADD TRANSACTIONDATE_CLEANED DATETIME;

UPDATE PRANALI_ASSESSMENT_22JAN2025
SET TRANSACTIONDATE_CLEANED = CONVERT(DATETIME,TRANSACTIONDATE,105);
--500000


--Min,Max date of transactions
SELECT MIN(TRANSACTIONDATE_CLEANED) as min_date,MAX(TRANSACTIONDATE_CLEANED) as max_date
FROM PRANALI_ASSESSMENT_22JAN2025
WHERE CAST(TRANSACTIONDATE_CLEANED AS DATE) > '1753-01-01';
--2022-01-01 00:00:00.000	2022-12-14 05:19:00.000

--Data with no trans_dates
SELECT COUNT(*)
FROM PRANALI_ASSESSMENT_22JAN2025
WHERE CAST(TRANSACTIONDATE_CLEANED AS DATE) < '1753-01-01';
--50000

SELECT COUNT(*),COUNT(CUSTOMERID),COUNT(DISTINCT CUSTOMERID)
FROM PRANALI_ASSESSMENT_22JAN2025
WHERE CAST(TRANSACTIONDATE_CLEANED AS DATE) < '1753-01-01';
--50000	0	0


--Convert here to Transaction amount to decimal
ALTER TABLE PRANALI_ASSESSMENT_22JAN2025
ALTER COLUMN TRANSACTIONAMOUNT NUMERIC;

--Convert here to quantity to decimal
ALTER TABLE PRANALI_ASSESSMENT_22JAN2025
ALTER COLUMN QUANTITY NUMERIC;

--Convert here to Discountpercent to decimal
ALTER TABLE PRANALI_ASSESSMENT_22JAN2025
ALTER COLUMN DISCOUNTPERCENT DECIMAL(10,2);

--Convert here to customerage to numeric
ALTER TABLE PRANALI_ASSESSMENT_22JAN2025
ALTER COLUMN CUSTOMERAGE NUMERIC;

--Convert here to FEEDBACKSCORE to numeric
ALTER TABLE PRANALI_ASSESSMENT_22JAN2025
ALTER COLUMN FEEDBACKSCORE NUMERIC;

--convert here delivery days to numeric
ALTER TABLE PRANALI_ASSESSMENT_22JAN2025
ALTER COLUMN DELIVERYTIMEDAYS NUMERIC;


--Convert here to SHIPPINGCOST to numeric
ALTER TABLE PRANALI_ASSESSMENT_22JAN2025
ALTER COLUMN SHIPPINGCOST DECIMAL(10,4);

--Convert here to LOYALTYPOINTS to numeric
ALTER TABLE PRANALI_ASSESSMENT_22JAN2025
ALTER COLUMN LOYALTYPOINTS NUMERIC;

---add column ot mt tag to varchar
ALTER TABLE PRANALI_ASSESSMENT_22JAN2025
alter column OT_MT_TAG varchar(500) ;

ALTER TABLE PRANALI_ASSESSMENT_22JAN2025
add  age_bucket varchar(500) ;

ALTER TABLE PRANALI_ASSESSMENT_22JAN2025
add spend_bucket_tag varchar(500)

ALTER TABLE PRANALI_ASSESSMENT_22JAN2025
ADD REACTIVATION_DAYS VARCHAR(500)

ALTER TABLE PRANALI_ASSESSMENT_22JAN2025
ADD loyalty_points_bucket VARCHAR(500)



---to fill missing values of payment method and region
;with cte as
(select customerid,paymentmethod,count(distinct transactionid) as no_of_transactions,
DENSE_RANK()over (partition by customerid order by count(distinct transactionid) desc) rnk
from PRANALI_ASSESSMENT_22JAN2025
group by customerid,paymentmethod)
update a
set a.paymentmethod =  cte.paymentmethod 
from PRANALI_ASSESSMENT_22JAN2025 a
inner join cte 
on a.CustomerID = cte.CustomerID
where a.PaymentMethod is null  and cte.rnk = 1

---to fill missing values of region where region is missing
;with cte as
(select customerid,region,count(distinct transactionid) as no_of_transactions,
DENSE_RANK()over (partition by customerid order by count(distinct transactionid) desc) rnk
from PRANALI_ASSESSMENT_22JAN2025
group by customerid,region)
update a
set a.Region =  cte.Region 
from PRANALI_ASSESSMENT_22JAN2025 a
inner join cte 
on a.CustomerID = cte.CustomerID
where a.Region = ''  and cte.rnk = 1

----to fill the customer age
;with cte as
(select customerid,max(CustomerAge) as age from PRANALI_ASSESSMENT_22JAN2025
group by customerid)
update a
set a.CustomerAge = cte.age
from PRANALI_ASSESSMENT_22JAN2025 a
join cte 
on a.CustomerID = cte.customerid
where a.Customerage = ''


---tagged one to multi time buyer AND SPEND BUCKET TAGGING
drop table #1
;with cte as
(select customerid,count(distinct cast(Transactiondate as date)) as visits,sum(TransactionAmount) as Total_spend_cust
from PRANALI_ASSESSMENT_22JAN2025
group by customerid)
select *,
case when visits = 1 then 'One-time'
else 'Multi-time'
end as OT_MT_TAG,
case 
when Total_spend_cust > 300000 then '>3L'
when Total_spend_cust between 250001 and 300000 then '2.5L-3L'
when Total_spend_cust between 200001 and 250000 then '2L-2.5L'
when Total_spend_cust between 150001 and 200000 then '1.5L-2L'
when Total_spend_cust between 100001 and 150000 then '1L-1.5L'
when Total_spend_cust between 50000 and 100000 then '50k-1L'
when Total_spend_cust between 0 and 50000 then '0-50K'
when Total_spend_cust < 0 then 'return'
end as Spend_bucket_tag
into #1
from cte 

update a
set a.OT_MT_TAG = b.OT_MT_TAG
from PRANALI_ASSESSMENT_22JAN2025 a
left join #1 b
on a.CustomerID = b.CustomerID

---no of ot mt customers 
SELECT OT_MT_TAG,COUNT(DISTINCT CUSTOMERID) AS CUSTS 
FROM PRANALI_ASSESSMENT_22JAN2025
GROUP BY OT_MT_TAG

update a
set a.spend_bucket_tag = b.spend_bucket_tag
from PRANALI_ASSESSMENT_22JAN2025 a
left join #1 b
on a.CustomerID = b.CustomerID 


-----no of high spender 
SELECT Spend_bucket_tag,COUNT(DISTINCT CUSTOMERID) AS CUSTS 
FROM PRANALI_ASSESSMENT_22JAN2025
GROUP BY Spend_bucket_tag

---Customers WIN BACK DAY tagging 
select distinct customerid,TransactionID,cast(transactiondate as date) as Trans_date
into #2
from PRANALI_ASSESSMENT_22JAN2025

IF OBJECT_ID('tempdb..#3') IS NOT NULL
DROP TABLE #3
;WITH CTE AS
(SELECT 
customerid,
TransactionID,
Trans_date,
DENSE_RANK()OVER(PARTITION BY customerid ORDER BY Trans_date) AS RNK
FROM #2)
SELECT * INTO #3 FROM CTE 

IF OBJECT_ID('tempdb..#PREVIOUS_CUSTS') IS NOT NULL   
DROP TABLE #PREVIOUS_CUSTS;  
    SELECT DISTINCT A.*, B.Trans_date AS PREV   
    INTO #PREVIOUS_CUSTS    
    FROM #3 A  
    LEFT JOIN #3 B  
        ON A.RNK = B.RNK + 1  
        AND A.CUSTOMERID = B.CUSTOMERID; 
		
    -- ASSIGNING PREVIOUS DATES TO CUSTOMERS  
    IF OBJECT_ID('tempdb..#TRANS_DUMP') IS NOT NULL   
        DROP TABLE #TRANS_DUMP;  
      
    SELECT A.*, B.PREV   
    INTO #TRANS_DUMP   
    FROM #3 A  
    LEFT JOIN #PREVIOUS_CUSTS B  
        ON A.CUSTOMERID = B.CUSTOMERID  
        AND A.TransactionID = B.TransactionID  
        AND CAST(A.Trans_date AS DATE) = B.Trans_date;

IF OBJECT_ID('tempdb..#DEDUP') IS NOT NULL   
DROP TABLE #DEDUP;  
;WITH CTE AS  
    (  
        SELECT *, ROW_NUMBER() OVER (PARTITION BY TransactionID ORDER BY Trans_date) AS RNK_1  
        FROM #TRANS_DUMP  
    )  
    SELECT * INTO #DEDUP FROM CTE WHERE RNK_1 = 1; 

 SELECT *,  
    DATEDIFF(DD, PREV, CAST(Trans_date AS DATE)) AS DAYS into #dedup_2 from #DEDUP


select a.*,b.days as days_1 into #reactivation_days_data from PRANALI_ASSESSMENT_22JAN2025 a
left join #dedup_2 b
on a.TransactionID = b.TransactionID ---500000

select count(*) from #reactivation_days_data
where days_1 is not null

select min(days_1),max(days_1) from #reactivation_days_data

select *,
case 
when days_1 between 0 and 60 then '0-60 days'
when days_1 between 61 and 180 then '61-180 days'
when days_1 between 181 and 240 then '181-240 days'
when days_1 > 240 then '> 240 days'
end as days_tag
into #sample_dataset_1
from #reactivation_days_data

UPDATE PRANALI_ASSESSMENT_22JAN2025
SET [AGE_BUCKET] = CASE
WHEN CUSTOMERAGE BETWEEN 18 AND 25 THEN '18-25'
WHEN CUSTOMERAGE BETWEEN 26 AND 35 THEN '26-35'
WHEN CUSTOMERAGE BETWEEN 36 AND 45 THEN '36-45'
WHEN CUSTOMERAGE BETWEEN 46 AND 55 THEN '46-55'
WHEN CUSTOMERAGE BETWEEN 56 AND 65 THEN '56-65'
WHEN CUSTOMERAGE BETWEEN 66 AND 75 THEN '66-75' END;

select min(loyaltypoints),max(loyaltypoints) from PRANALI_ASSESSMENT_22JAN2025


Select *,
case 
when loyaltypoints between 0 and 2000 then '0-2000'
when loyaltypoints between 2001 and 4000 then '2001-4000'
when loyaltypoints between 4001 and 6000 then '4001-6000'
when loyaltypoints between 6001 and 8000 then '6001-8000'
when loyaltypoints > 8000 then 'greater than 8000'
end as loyalty_point_bucket
into #4
from PRANALI_ASSESSMENT_22JAN2025

UPDATE PRANALI_ASSESSMENT_22JAN2025
SET loyalty_points_bucket = CASE
when loyaltypoints between 0 and 2000 then '0-2000'
when loyaltypoints between 2001 and 4000 then '2001-4000'
when loyaltypoints between 4001 and 6000 then '4001-6000'
when loyaltypoints between 6001 and 8000 then '6001-8000'
when loyaltypoints > 8000 then 'greater than 8000' END;

select loyalty_point_bucket,count(distinct transactionid) as transactions
from #4
group by loyalty_point_bucket


UPDATE A
SET A.REACTIVATION_DAYS = B.days_tag
FROM PRANALI_ASSESSMENT_22JAN2025 A
JOIN #sample_dataset_1 B
ON A.TransactionID = B.TransactionID


------Exploration of data statistics wise

--Transaction date --To find the range within net spend lies
SELECT MIN(TransactionDate),MAX(TransactionDate)
FROM PRANALI_ASSESSMENT_22JAN2025
where TransactionDate > '1753-01-01'
 --'2022-01-01' 	'2022-12-14'

------To find minimum and max spend on bill value of customers
SELECT MIN(TRANSACTIONAMOUNT),MAX(TRANSACTIONAMOUNT)
FROM PRANALI_ASSESSMENT_22JAN2025

--Discount
SELECT DISCOUNTPERCENT,CAST(DISCOUNTPERCENT AS NUMERIC),CAST(DISCOUNTPERCENT AS DECIMAL(10,2))
FROM PRANALI_ASSESSMENT_22JAN2025


SELECT MIN(DISCOUNTPERCENT),MAX(CAST(DISCOUNTPERCENT AS DECIMAL(10,2)))
FROM PRANALI_ASSESSMENT_22JAN2025
--0.00	50.00

--OVERAL
SELECT COUNT(*) NO_OF_TRANS,
COUNT(DISTINCT CUSTOMERID) DIS_CUST,
COUNT(DISTINCT CASE WHEN TransactionAmount > 0 THEN CUSTOMERID END) DIS_CUST_PURCH,
COUNT(DISTINCT CASE WHEN TransactionAmount < 0 THEN CUSTOMERID END) DIS_CUST_RETURN,
SUM(QUANTITY) TOT_QTY,
SUM(CASE WHEN TransactionAmount > 0 THEN QUANTITY END) TOT_QUAN_PURCH,
SUM(CASE WHEN TransactionAmount < 0 THEN QUANTITY END) TOT_QUAN_RETURNED,
SUM(TRANSACTIONAMOUNT) TOT_SALES,
SUM(CASE WHEN TransactionAmount > 0 THEN TRANSACTIONAMOUNT END) TOT_PURCH_AMT,
SUM(CASE WHEN TransactionAmount < 0 THEN TRANSACTIONAMOUNT END) TOT_RETURNED_AMT,
SUM(SHIPPINGCOST) TOT_SHIP_COST
FROM PRANALI_ASSESSMENT_22JAN2025

--MOM
SELECT YEAR(TRANSACTIONDATE_CLEANED),MONTH(TRANSACTIONDATE_CLEANED),
COUNT(*) NO_OF_TRANS,
COUNT(DISTINCT CUSTOMERID) DIS_CUST,
COUNT(DISTINCT CASE WHEN TransactionAmount > 0 THEN CUSTOMERID END) DIS_CUST_PURCH,
COUNT(DISTINCT CASE WHEN TransactionAmount < 0 THEN CUSTOMERID END) DIS_CUST_RETURN,
SUM(QUANTITY) TOT_QTY,
SUM(CASE WHEN  TransactionAmount > 0 THEN QUANTITY END) TOT_QUAN_PURCH,
SUM(CASE WHEN TransactionAmount < 0 THEN QUANTITY END) TOT_QUAN_RETURNED,
SUM(TRANSACTIONAMOUNT) TOT_SALES,
SUM(CASE WHEN TransactionAmount > 0 THEN TRANSACTIONAMOUNT END) TOT_PURCH_AMT,
SUM(CASE WHEN TransactionAmount < 0 THEN TRANSACTIONAMOUNT END) TOT_RETURNED_AMT,
SUM(SHIPPINGCOST) TOT_SHIP_COST
FROM PRANALI_ASSESSMENT_22JAN2025
GROUP BY YEAR(TRANSACTIONDATE_CLEANED),MONTH(TRANSACTIONDATE_CLEANED)
order by YEAR(TRANSACTIONDATE_CLEANED),MONTH(TRANSACTIONDATE_CLEANED)

--Pay method
SELECT PAYMENTMETHOD,
COUNT(*) NO_OF_TRANS,
COUNT(DISTINCT CUSTOMERID) DIS_CUST,
COUNT(DISTINCT CASE WHEN TransactionAmount > 0 THEN CUSTOMERID END) DIS_CUST_PURCH,
COUNT(DISTINCT CASE WHEN TransactionAmount < 0 THEN CUSTOMERID END) DIS_CUST_RETURN,
SUM(QUANTITY) TOT_QTY,
SUM(CASE WHEN TransactionAmount > 0 THEN QUANTITY END) TOT_QUAN_PURCH,
SUM(CASE WHEN TransactionAmount < 0 THEN QUANTITY END) TOT_QUAN_RETURNED,
SUM(TRANSACTIONAMOUNT) TOT_SALES,
SUM(CASE WHEN TransactionAmount > 0 THEN TRANSACTIONAMOUNT END) TOT_PURCH_AMT,
SUM(CASE WHEN TransactionAmount < 0 THEN TRANSACTIONAMOUNT END) TOT_RETURNED_AMT,
SUM(SHIPPINGCOST) TOT_SHIP_COST
FROM PRANALI_ASSESSMENT_22JAN2025
GROUP BY PAYMENTMETHOD
ORDER BY COUNT(*) DESC

--City
SELECT CITY,
COUNT(*) NO_OF_TRANS,
COUNT(DISTINCT CUSTOMERID) DIS_CUST,
COUNT(DISTINCT CASE WHEN TransactionAmount > 0 THEN CUSTOMERID END) DIS_CUST_PURCH,
COUNT(DISTINCT CASE WHEN TransactionAmount < 0 THEN CUSTOMERID END) DIS_CUST_RETURN,
SUM(QUANTITY) TOT_QTY,
SUM(CASE WHEN TransactionAmount > 0 THEN QUANTITY END) TOT_QUAN_PURCH,
SUM(CASE WHEN TransactionAmount < 0 THEN QUANTITY END) TOT_QUAN_RETURNED,
SUM(TRANSACTIONAMOUNT) TOT_SALES,
SUM(CASE WHEN TransactionAmount > 0 THEN TRANSACTIONAMOUNT END) TOT_PURCH_AMT,
SUM(CASE WHEN TransactionAmount < 0 THEN TRANSACTIONAMOUNT END) TOT_RETURNED_AMT,
SUM(SHIPPINGCOST) TOT_SHIP_COST
FROM PRANALI_ASSESSMENT_22JAN2025
GROUP BY CITY
order by COUNT(*) desc

--Store Type
UPDATE PRANALI_ASSESSMENT_22JAN2025
SET STORETYPE = NULL
WHERE STORETYPE = '';
--50000

SELECT STORETYPE,
COUNT(*) NO_OF_TRANS,
COUNT(DISTINCT CUSTOMERID) DIS_CUST,
COUNT(DISTINCT CASE WHEN TransactionAmount > 0 THEN CUSTOMERID END) DIS_CUST_PURCH,
COUNT(DISTINCT CASE WHEN TransactionAmount < 0 THEN CUSTOMERID END) DIS_CUST_RETURN,
SUM(QUANTITY) TOT_QTY,
SUM(CASE WHEN TransactionAmount > 0 THEN QUANTITY END) TOT_QUAN_PURCH,
SUM(CASE WHEN TransactionAmount < 0 THEN QUANTITY END) TOT_QUAN_RETURNED,
SUM(TRANSACTIONAMOUNT) TOT_SALES,
SUM(CASE WHEN TransactionAmount > 0 THEN TRANSACTIONAMOUNT END) TOT_PURCH_AMT,
SUM(CASE WHEN TransactionAmount < 0 THEN TRANSACTIONAMOUNT END) TOT_RETURNED_AMT,
SUM(SHIPPINGCOST) TOT_SHIP_COST
FROM PRANALI_ASSESSMENT_22JAN2025
GROUP BY STORETYPE;

--Age Bucket
SELECT AGE_BUCKET,
COUNT(*) NO_OF_TRANS,
COUNT(DISTINCT CUSTOMERID) DIS_CUST,
COUNT(DISTINCT CASE WHEN TransactionAmount > 0 THEN CUSTOMERID END) DIS_CUST_PURCH,
COUNT(DISTINCT CASE WHEN TransactionAmount < 0 THEN CUSTOMERID END) DIS_CUST_RETURN,
SUM(QUANTITY) TOT_QTY,
SUM(CASE WHEN TransactionAmount > 0 THEN QUANTITY END) TOT_QUAN_PURCH,
SUM(CASE WHEN TransactionAmount < 0 THEN QUANTITY END) TOT_QUAN_RETURNED,
SUM(TRANSACTIONAMOUNT) TOT_SALES,
SUM(CASE WHEN TransactionAmount > 0 THEN TRANSACTIONAMOUNT END) TOT_PURCH_AMT,
SUM(CASE WHEN TransactionAmount < 0 THEN TRANSACTIONAMOUNT END) TOT_RETURNED_AMT,
SUM(SHIPPINGCOST) TOT_SHIP_COST
FROM PRANALI_ASSESSMENT_22JAN2025
GROUP BY AGE_BUCKET
ORDER BY COUNT(*);

---Customer Gender
UPDATE PRANALI_ASSESSMENT_22JAN2025
SET CUSTOMERGENDER = NULL
WHERE CUSTOMERGENDER = '';

SELECT CUSTOMERGENDER,
COUNT(*) NO_OF_TRANS,
COUNT(DISTINCT CUSTOMERID) DIS_CUST,
COUNT(DISTINCT CASE WHEN TransactionAmount > 0 THEN CUSTOMERID END) DIS_CUST_PURCH,
COUNT(DISTINCT CASE WHEN TransactionAmount < 0 THEN CUSTOMERID END) DIS_CUST_RETURN,
SUM(QUANTITY) TOT_QTY,
SUM(CASE WHEN TransactionAmount > 0 THEN QUANTITY END) TOT_QUAN_PURCH,
SUM(CASE WHEN TransactionAmount < 0 THEN QUANTITY END) TOT_QUAN_RETURNED,
SUM(TRANSACTIONAMOUNT) TOT_SALES,
SUM(CASE WHEN TransactionAmount > 0 THEN TRANSACTIONAMOUNT END) TOT_PURCH_AMT,
SUM(CASE WHEN TransactionAmount < 0 THEN TRANSACTIONAMOUNT END) TOT_RETURNED_AMT,
SUM(SHIPPINGCOST) TOT_SHIP_COST
FROM PRANALI_ASSESSMENT_22JAN2025
GROUP BY CUSTOMERGENDER
order by count(*) desc;

--Product Name
UPDATE PRANALI_ASSESSMENT_22JAN2025
SET PRODUCTNAME = NULL
WHERE PRODUCTNAME = '';
--50000

SELECT PRODUCTNAME,
COUNT(*) NO_OF_TRANS,
COUNT(DISTINCT CUSTOMERID) DIS_CUST,
COUNT(DISTINCT CASE WHEN TransactionAmount > 0 THEN CUSTOMERID END) DIS_CUST_PURCH,
COUNT(DISTINCT CASE WHEN TransactionAmount < 0 THEN CUSTOMERID END) DIS_CUST_RETURN,
SUM(QUANTITY) TOT_QTY,
SUM(CASE WHEN TransactionAmount > 0 THEN QUANTITY END) TOT_QUAN_PURCH,
SUM(CASE WHEN TransactionAmount < 0 THEN QUANTITY END) TOT_QUAN_RETURNED,
SUM(TRANSACTIONAMOUNT) TOT_SALES,
SUM(CASE WHEN TransactionAmount > 0 THEN TRANSACTIONAMOUNT END) TOT_PURCH_AMT,
SUM(CASE WHEN TransactionAmount < 0 THEN TRANSACTIONAMOUNT END) TOT_RETURNED_AMT,
SUM(SHIPPINGCOST) TOT_SHIP_COST
FROM PRANALI_ASSESSMENT_22JAN2025
GROUP BY PRODUCTNAME
order by count(*) desc

--Region
UPDATE PRANALI_ASSESSMENT_22JAN2025
SET REGION = NULL
WHERE REGION = '';
--42633

SELECT REGION,
COUNT(*) NO_OF_TRANS,
COUNT(DISTINCT CUSTOMERID) DIS_CUST,
COUNT(DISTINCT CASE WHEN TransactionAmount > 0 THEN CUSTOMERID END) DIS_CUST_PURCH,
COUNT(DISTINCT CASE WHEN TransactionAmount < 0 THEN CUSTOMERID END) DIS_CUST_RETURN,
SUM(QUANTITY) TOT_QTY,
SUM(CASE WHEN TransactionAmount > 0 THEN QUANTITY END) TOT_QUAN_PURCH,
SUM(CASE WHEN TransactionAmount < 0 THEN QUANTITY END) TOT_QUAN_RETURNED,
SUM(TRANSACTIONAMOUNT) TOT_SALES,
SUM(CASE WHEN TransactionAmount > 0 THEN TRANSACTIONAMOUNT END) TOT_PURCH_AMT,
SUM(CASE WHEN TransactionAmount < 0 THEN TRANSACTIONAMOUNT END) TOT_RETURNED_AMT,
SUM(SHIPPINGCOST) TOT_SHIP_COST
FROM PRANALI_ASSESSMENT_22JAN2025
GROUP BY REGION
order by count(*);

---Relation between storetype and age_bucket
select [StoreType],age_bucket,count(TransactionID) as no_of_transactions,count(distinct customerid) as no_of_transactions
from PRANALI_ASSESSMENT_22JAN2025
group by [StoreType],age_bucket.
---Relation between productname and payment method

select productname,paymentmethod,count(TransactionID) as no_of_transactions,count(distinct customerid) as no_of_custs
from PRANALI_ASSESSMENT_22JAN2025
group by productname,paymentmethod

select count(TransactionID),count(distinct Transactionid) from 
PRANALI_ASSESSMENT_22JAN2025
---Relation between productname and age_bucket
select productname,age_bucket,count(TransactionID) as no_of_transactions,count(distinct customerid) as no_of_custs
from PRANALI_ASSESSMENT_22JAN2025
group by productname,age_bucket

---Relation between spend bucket tag
select spend_bucket_tag,count(distinct customerid) as custs 
from PRANALI_ASSESSMENT_22JAN2025
group by spend_bucket_tag

--relation between region and spend_bucket_tag
select spend_bucket_tag,region,count(distinct customerid) as custs,
count(distinct transactionid) as no_of_bills 
from PRANALI_ASSESSMENT_22JAN2025
group by spend_bucket_tag,region


---Relation between productname,spend_bucket_tag and ot_mt_tag
select productname,spend_bucket_tag,ot_mt_tag,count(distinct customerid) as custs,sum(Quantity) as Net_sales
from PRANALI_ASSESSMENT_22JAN2025
group by productname,spend_bucket_tag,ot_mt_tag

---Relation between loyalty points bucket and no of transactions
select Loyalty_Points_bucket,
count(distinct customerid) as custs,count(distinct TransactionID) as transactions
from PRANALI_ASSESSMENT_22JAN2025
group by Loyalty_Points_bucket
order by custs asc

select customerid,sum(transaction_amount) as sales from PRANALI_ASSESSMENT_22JAN2025
group by customerid

select customergender,spend_bucket_tag,count(distinct customerid) as custs
from PRANALI_ASSESSMENT_22JAN2025
group by customergender,spend_bucket_tag

---Product name and feedback
select Productname,FeedbackScore,count(distinct TransactionID) as Trans
from PRANALI_ASSESSMENT_22JAN2025
group by Productname,FeedbackScore

---city vs products
select Productname,city,count(distinct TransactionID) as Trans,sum(quantity) as quant,count(distinct customerid) as custs
from PRANALI_ASSESSMENT_22JAN2025
group by Productname,city

---Reactivation Days
select REACTIVATION_DAYS,count(distinct customerid) as custs
from PRANALI_ASSESSMENT_22JAN2025
group by REACTIVATION_DAYS












