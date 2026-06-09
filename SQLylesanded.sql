------------------Päringu ülesanded----------------------

--1.
create function dbo.GetAllCustomers_ITVF
(
)
returns table
as
return
(
	select * 
	from SalesLT.Customer
)
Go

--2.

create function GetCustomerByID_ITVF
(
@CustomerID int
)
returns table
as
return 
(
	select FirstName, LastName
	from SalesLT.Customer
	where CustomerID = @CustomerID
)

--3.
create function GetOrdersByCustomer_ITVF
(
@CustomerID int
)
returns table
as 
return 
(
	select *
	from SalesLT.SalesOrderHeader
	where CustomerID = @CustomerID
)

--4. 
create function GetProductsByPrice_ITVF
(
@MinPrice money,
@MaxPrice money
)
returns table
as
return
(
	select *
	from SalesLT.Product
	where ListPrice between @MinPrice and @MaxPrice
)

--5.
create function GetTopExpensiveProducts_ITVF
(
)
returns table
as
return
(
	select top 10 *
	from SalesLT.Product
	order by ListPrice desc
)

--6.
create function GetCustomerFullInfo_MSTVF
(
@CustomerID int
)
returns @Result table
(
	FullName NVARCHAR(150),
	Email NVARCHAR(50),
	Phone NVARCHAR(25)
)
as
begin
	insert into @Result (FullName, Email, Phone)
	select 
		FirstName + '' + LastName,
		EmailAddress,
		Phone
	from
		SalesLT.Customer
	where 
		CustomerID = @CustomerID
	return
end

--7.
create function GetCustomerOrderSummary_MSTVF
(
@CustomerID int
)
returns @Result table
(
	OrderCount int,
	TotalAmount money
)
as
begin
	insert into @Result (OrderCount, TotalAmount)
	select
		count(SalesOrderID),
		isnull(SUM(TotalDue), 0)
	from
		SalesLT.SalesOrderHeader
	where 
		CustomerID = @CustomerID
	return
end


--8.
create function GetProductPriceCategory_MSTVF
(
)
returns @Result table
(
	ProductID int,
	Name NVARCHAR(50),
	ListPrice money,
	PriceCategory NVARCHAR(20)
)
as
begin
	insert into @Result (ProductID, Name, ListPrice, PriceCategory)
	select
		ProductID,
		Name,
		ListPrice,
		case	
			when ListPrice < 100 then 'odav'
			when ListPrice >= 100 and ListPrice <= 1000 then 'keskmine'
			else 'kallis'
		end
	from
		SalesLT.Product

	return
end

--9.
create function GetCustomerWithOrders_MSTVF
(
)
returns @Result table 
(
	CustomerID int,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50)
)
as
begin
	insert into @Result (CustomerID, FirstName, LastName)
	select
		c.CustomerID,
		c.FirstName,
		c.LastName
	from
		SalesLT.Customer as c
	where
		exists (
			select 1
			from SalesLT.SalesOrderHeader as soh
			where soh.CustomerID = c.CustomerID
		)
	return
end

--10.

create function GetTopCustomersBySpending_MSTVF()
returns @Result table
(
	CustomerID int,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	TotalSpent money
)
as
begin 
	insert into @Result (CustomerID, FirstName, LastName, TotalSpent)
	select top 5
		c.CustomerID,
		c.FirstName,
		c.LastName,
		sum(soh.TotalDue) as TotalSpent
	from
		SalesLT.Customer as c
	inner join
		SalesLT.SalesOrderHeader as soh on c.CustomerID = soh.CustomerID
	group by
		c.CustomerID,
		c.FirstName,
		c.LastName
	order by
		TotalSpent DESC
	return
end
