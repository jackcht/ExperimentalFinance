/* -- Assignment 1 -- */

/* 
	PROBLEM SET 1 -- An introduction to SQL
		Explore the tables and return some data for security, security_price, option_price. Get
		familiar with the columns and looking at the data. You can use SELECT TOP 100 * FROM
		<table>. (This will return only the first 100 rows. Do not forget this down the road since
		you will otherwise be returning all the data in the database.)
*/

/*-----------------------------------------------------------------------------------*/
-- Q1: How many unique tickers are listed in IVY?

SELECT COUNT(DISTINCT Ticker) FROM XFDATA.dbo.SECURITY;




/*-----------------------------------------------------------------------------------*/
-- Q2: Pick a day, how many unique tickers trade?

select COUNT(DISTINCT temp1.Ticker) from (
	SELECT Ticker, Date, BidLow from XFDATA.dbo.SECURITY_PRICE sp
	join XFDATA.dbo.SECURITY s
	on sp.SecurityID = s.SecurityID
	)As temp1
WHERE (DATEPART(yy, temp1.Date) = 2013 AND DATEPART(mm, temp1.Date) = 08 AND DATEPART(dd, temp1.Date) = 01)
and BidLow > 0




/*-----------------------------------------------------------------------------------*/
-- Q3: Select all options on a particular day for an optionable stock 
--(i.e. for which options are listed) beginning with the first letter of your last name

select * From XFDATA.dbo.Option_Volume ov
JOIN XFDATA.dbo.Security sc
ON ov.SecurityID = sc.SecurityID
Where sc.Ticker LIKE 'C%' AND sc.IssueType = '0'
AND (DATEPART(yy, Date) = 2013 AND DATEPART(mm, Date) = 08 AND DATEPART(dd, Date) = 01)




/*-----------------------------------------------------------------------------------*/
-- Question 4: Count all stocks trading at the beginning of each year for all years in the database.

select COUNT(distinct SecurityID) from (
	select DATEPART(yy, sp.Date) as YY, Date, s.SecurityID from XFDATA.dbo.SECURITY s
	join XFDATA.dbo.SECURITY_PRICE sp
	on sp.SecurityID = s.SecurityID
	where IssueType = '0'
	and Date in (
	select min(Date) as Date from XFDATA.dbo.SECURITY_PRICE as sp
	group by DATEPART(yy, sp.Date)
	))
as temp




/*-----------------------------------------------------------------------------------*/
-- Question 5: What is the (sematic) difference between the two queries below? 
-- Explain clearly with no more than 3-4 lines.

SELECT s.*, sp.*
FROM XFDATA.dbo.security s
LEFT JOIN XFDATA.dbo.security_price sp
ON s.securityID=sp.securityID AND sp.date='2010-01-15'
WHERE sp.closePrice is null

/* -- Query 1 first returns all rows from security and matched rows from Security_Price 
where SecurityID matches and Date='2010-01-15', then select all from the joined table.
*/

SELECT ticker
FROM XFDATA.dbo.security s
LEFT JOIN XFDATA.dbo.security_price sp
ON s.securityID=sp.securityID
WHERE 
sp.closePrice is null AND sp.date='2010-01-15'

/* -- Query 2 first returns all rows from the security and matched rows from security_price 
where SecurityID matches then select ticker out of the joined table. 
*/



/*-----------------------------------------------------------------------------------*/
-- Question 6:  Strike values are stored as integers in IVY. They corresponds to a multiple of the 
-- real strike of the option, i.e. IVY-strike=1000*real-strike. Create a query that returns the real
-- dollar value of an option strike. Warning: don't make rounding errors!

select (Strike/1000.0) as RealStrike from XFDATA.dbo.OPTION_PRICE_2013_08 
where OptionID=100269601 and Date='2013-08-08'



/*-----------------------------------------------------------------------------------*/
-- Question 7: Using Matlab: a) plot the (adjusted) price of Coca Cola over the year 2012. Adjusted 
-- means that you need to account for splits; b) plot the histogram of returns; c) find those days 
-- for which the stock return exceeds (in absolute terms) 3.7%.

-- a)
select sp.Date, sp.ClosePrice/4*sp.AdjustmentFactor as AdjustedPrice 
from XFDATA.dbo.SECURITY s
join XFDATA.dbo.SECURITY_PRICE sp
on sp.SecurityID = s.SecurityID
where s.ticker='KO' and DATEPART(yy, sp.date) = 2012

--c)
select DATE from (
	select sp.Date, sp.ClosePrice/4*sp.AdjustmentFactor as AdjustedPrice, sp.TotalReturn from XFDATA.dbo.SECURITY s
	join XFDATA.dbo.SECURITY_PRICE sp
	on sp.SecurityID = s.SecurityID
	where s.ticker='KO' and DATEPART(yy, sp.date) = 2012
	) as temp
where abs(temp.TotalReturn) > 0.037



/*-----------------------------------------------------------------------------------*/
-- Question 8: Select the minimum and maximum prices by month, for a stock of your choosing.

SELECT temp.SecurityID, DATEPART(Year, temp.Date) Year, DATEPART(Month, temp.Date) Month, min(temp.ClosePrice) as MinValue, max(temp.ClosePrice) as MaxValue 
FROM (
	select s.SecurityID, Date,IssueType, ClosePrice from XFDATA.dbo.SECURITY s
	join XFDATA.dbo.SECURITY_PRICE sp
	on s.SecurityID = sp.SecurityID
	where IssueType = '0' and s.SecurityID = 103125
	)as temp
GROUP BY DATEPART(Year, temp.Date), DATEPART(Month, temp.Date),temp.SecurityID
ORDER BY Year, Month


/*-----------------------------------------------------------------------------------*/
-- Question 9: For each day in a month of your choosing, find the at-the-money (ATM) strike for a particular stock. How many values does it take?




/*-----------------------------------------------------------------------------------*/
-- Question 10: Consider the company PG. In Matlab:  a) Plot the implied volatility surface on 03/03/2008. Avoid bad values, i.e. IV<0. You can replace bad values 
-- with NaN in order to plot in Matlab. b) For the period Jan 2008 to Jan 2009, find the IV of the ATM (at the money) front month (i.e. with closest expiration) 
-- option and plot it against time. Again, avoid bad values using NaN.

select * from XFDATA.dbo.SECURITY s where s.Ticker='PG'				
-- we found that the PG'secuity id = 109224

select ImpliedVolatility,Date from XFDATA.dbo.VOLATILITY_SURFACE_2008_03 vs 
where vs.SecurityID = 109224 and DATEPART(dd, vs.Date) = 03



/*-----------------------------------------------------------------------------------*/
-- Question 11: Count the number of option prices in a one-month period, grouped by week. 

select COUNT(*) num, DATEPART(wk, op.Date)-26 week 
from XFDATA.dbo.OPTION_PRICE_2013_07 op
group by DATEPART(wk, op.Date)-26



/*-----------------------------------------------------------------------------------*/
-- Question 12: Find all non-optionable stocks. 

select * from (
select * from SECURITY where IssueType = '0'
)temp1
left join (
select distinct securityID from option_volume 
) temp2
on temp1.SecurityID = temp2.SecurityID
where temp2.SecurityID is null



