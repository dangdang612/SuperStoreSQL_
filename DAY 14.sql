#Using Superstore database
#1. Top 10 products with the highest number of returned products?
select Product_ID, Product_Name, Sum(Quantity)
from tien_sql.orders ord
	inner join tien_sql.returns ret 
		on ord.Order_ID = ret.Order_ID
Group by Product_ID
Order by Sum(Quantity) desc
Limit 10
# 2. Top 10 cities with highest Sales per returned order?
select city 
		, Sum(Sales)/Count(distinct ret.Order_ID) as Sales_Returned_Order
from tien_sql.orders ord
		right join tien_sql.returns ret 
			on ord.Order_ID = ret.Order_ID
Group by city
Order by Sales_Returned_Order desc
Limit 10
#3. Get a list of all customers that have returned at least 1 order. 
In this list, we need following information
--Name
--Customer ID
--Segment
--Number of returned orders
--Total Sales of Returned orders
Select Customer_name, Customer_ID
		,Segment
		,Count(distinct ret.Order_ID) as NumberofReturnedOrders
        ,Sum(Sales) as Total_Sales_Returned
from tien_sql.orders ord
	right join tien_sql.returns ret
		on ord.Order_ID = ret.Order_ID
Group By Customer_name, Customer_ID
Order By Total_Sales_Returned desc

#Use Bookshop database
#1. Get AVG Rating and Number of Rating per Book
select distinct boo.BookID, rat.BookID
	,avg(Rating) as AVG_Rating
    ,Sum(Rating)/count(distinct rat.BookID) as NumberofRating_Book
from bookshop.books boo
	right join bookshop.rating rat
		on boo.BookID = rat.BookID
group by boo.BookID
union all
select distinct boo.BookID, rat.BookID
		,avg(rating) as AVG_Rating
        ,Sum(Rating)/count(distinct boo.BookID) as NumberofRating_Book
from bookshop.books boo
	left join bookshop.rating rat
		on boo.BookID = rat.BookID
group by boo.BookID

#2. Get AVG rating and Number of Rating per Author
select distinct boo.BookID, rat.BookID, aut.AuthID
		,avg(Rating)
        ,sum(rating)/count(distinct aut.AuthID)
from bookshop.books boo
	right join bookshop.rating rat
    on boo.BookID = rat.BookID
    right join bookshop.authors aut
    on boo.AuthID = aut.AuthID
group by boo.BookID, rat.BookID, aut.AuthID
union 
select distinct boo.BookID, rat.BookID, aut.AuthID
		,avg(rating)
        ,sum(rating)/count(distinct aut.AuthID)
from bookshop.books boo
	left join bookshop.rating rat
    on boo.BookID = rat.BookID
    left join bookshop.authors aut
    on boo.AuthID = aut.AuthID
group by boo.BookID, rat.BookID, aut.AuthID

#3. Get Number of Books (items) Sold and Total Sales Q1 of all books
select count(distinct concat(sal.ItemID, sal.OrderID)) as NumberofItemsSold
		,sum(case when discount is not null then (1- sal.discount)*edi.price
        else edi.price end) as Total_Sales
from bookshop.edition edi
	join bookshop.sales_q1 sal 
		on sal.ISBN = edi.ISBN
#4. How many copies of AWARDED books have been sold in Q1 and total sales of each book?
select  awa.Title, boo.BookID
		,sum(`Number of Copies`) as NumberofCopies
		,sum(case when Discount is not null then (1-Discount)*Price
       else Price end) as Total_Sales
from bookshop.books boo
	join bookshop.edition edi
		on boo.BookID = edi.BookID
    join bookshop.sales_q1 sal
		on edi.ISBN = sal.ISBN
	left join (select distinct Title
			from bookshop.award) awa
		on boo.Title = awa.Title
	join bookshop.catalog cat
		on sal.ISBN = cat.ISBN
where awa.Title is not null
group by awa.Title, boo.BookID
#5. Top 3 Book Genre each month in Q1 in terms of number of book sold.
with new2 as (
with new_table as (
	select concat(BookID1, BookID2) as BookID, genre
    from bookshop.info
    )
select  month(STR_TO_DATE(`Sale Date`, '%Y/%m/%D')) 
		,Genre
		,sum(case when sal.discount is not null then (1-discount)*price
		else price end) as Total_Sales
        ,row_number() over (partition by month(STR_TO_DATE(`Sale Date`, '%Y/%m/%D')) 
        order by sum(case when sal.discount is not null then (1-discount)*price
		else price end) desc) as rank_
from new_table
	join bookshop.edition edi
		on new_table.BookID = edi.BookID
	right join bookshop.sales_q1 sal
		on edi.ISBN = sal.ISBN
group by Genre
		,month(STR_TO_DATE(`Sale Date`, '%Y/%m/%D'))
)
select *
from new2
where rank_ < 4
		