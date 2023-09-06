#check cleanliness and duplicate value in dataset
select count(*),count(distinct Order_ID)
			,count(distinct Customer_ID),count(distinct Product_ID)
		 ,count(Order_ID&Product_ID)
from superstore.order

#Question1: How many orders/Total Revenues do each customer purchase?
Select Customer_ID,Customer_Name, Segment, Category
		,count(Order_ID)as TotalOrders, count(Product_ID)
		,sum(Sales)as TotalRevenue
		,sum(Sales)/count(Order_ID) as RevenuePerOrder
from superstore.order
group by Customer_ID,Customer_Name, Segment,Category 
order by sum(Sales) desc

#Question 2: In the last 6 months since the current date, how many customers reached the highest revenue?
select Customer_ID,Customer_Name, Segment, Category 
		,sum(case when Order_Date <= '2017-12-30' 
			and Order_Date > date_add('2017-12-30', interval -6 month)
			then Sales end) as TotalSalesin6Months
from superstore.order
group by Customer_ID,Customer_Name, Segment, Category 
order by sum(case when Order_Date <= '2017-12-30' 
			and Order_Date > date_add('2017-12-30', interval -6 month)
			 then Sales end)desc
             
#Question 3: How many days is since the latest orders?
with MaxOrders as
(select Category, Sub_Category, Customer_ID,Customer_Name, max(Order_Date) MaxOrderDate
from orders 
group by Category, Sub_Category, Customer_ID 
)
select Category, Sub_Category, Customer_ID,Customer_Name, MaxOrderDate
		,datediff('2017-12-30', MaxOrderDate) NumberDays
from MaxOrders
group by Category, Sub_Category, Customer_ID
order by NumberDays desc