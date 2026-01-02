/*
🔹 LEVEL 1 — Core SQL Fundamentals (Must-know)
1. Count total records in the dataset.​

2. Find the number of unique countries, markets, and commodities.​

3. Identify the earliest and latest date available.​

4. List all commodities sold in more than 5 countries.​

5. Find the top 10 most frequently recorded commodities.​

6. Show average price_usd per commodity.​

7. Find the country with the highest average food price.​

8. Identify commodities where price_usd is NULL or zero.​

9. Find markets that have only one commodity listed.​

10. Count records per year.​


🔹 LEVEL 2 — Business-Driven Aggregations

11. Compute average, minimum, and maximum price per commodity.​

12. Compare average prices of the same commodity across countries.​

13. Identify the most expensive commodity per country.​

14. Find the cheapest market for each commodity.​

15. Rank countries by overall average food price.​

16. Show year-wise average food prices globally.​

17. Identify the top 3 commodities contributing to high prices in each country.​

18. Find commodities with price ranges (max − min) greater than X.​

19. Compare local currency prices vs USD prices (consistency check).​

20. Identify markets where prices are consistently above country average.​


🔹 LEVEL 3 — Time Series & Inflation Analysis (INTERVIEW FAVORITE)
21. Calculate Year-over-Year (YoY) price change per commodity.​

22. Identify the year with the highest average inflation globally.​

23. Find commodities with continuous price increase for 3+ years.​

24. Compute Month-over-Month (MoM) price change.​

25. Detect price spikes (>25% increase) between consecutive periods.​

26. Identify countries where food prices doubled over the dataset period.​

27. Rank commodities by long-term price growth.​

28. Find volatile commodities using standard deviation.​

29. Compare inflation trends between two selected countries.​

30. Identify years of price instability during crises (e.g., 2008, 2020).​


🔹 LEVEL 4 — Advanced SQL (Window Functions & Analytics)

31. Use LAG() to compare current vs previous year prices.​

32. Calculate rolling 3-year average price per commodity.​

33. Rank commodities within each country by price.​

34. Identify consecutive inflation years using window functions.​

35. Find markets that show abnormal deviation from national trends.​

36. Detect structural breaks (sudden regime shifts in pricing).​

37. Find the top 5 worst inflation events by magnitude.​

38. Compare urban vs rural market pricing (if applicable).​

39. Create a price index per country using a base year.​

40. Flag commodities with high price volatility & upward trend.​


🔹 LEVEL 5 — Real-World Policy & Risk Scenarios (Senior Analyst Level)

41. If the government can subsidize only one commodity, which one shows the steepest long-term price rise?​

42. Which countries are at highest food security risk based on inflation trends?​


*/ 
/*Alter Table  global_wfp_food_prices.wfp_food_prices
Add Column commodity_name VARCHAR(255);

UPDATE global_wfp_food_prices.wfp_food_prices
SET commodity_name = TRIM(SUBSTRING_INDEX(commodity, '(', 1))
WHERE commodity LIKE '%(%';
*/

SELECT * FROM global_wfp_food_prices.wfp_food_prices;


# 1. Count total records in the dataset.​
SELECT count(*) as Total_Rows FROM global_wfp_food_prices.wfp_food_prices;

# 2. Find the number of unique countries, markets, and commodities.​
select count(distinct country_code) unique_countries,count(distinct market) unique_market,count(distinct commodity) as unique_commodity
FROM global_wfp_food_prices.wfp_food_prices;


# 3. Identify the earliest and latest date available.​
select MIN(date) as "Earliest Date",MAX(date) as "Latest Date"
FROM global_wfp_food_prices.wfp_food_prices;



# 4. List all commodities sold in more than 5 countries.​
select commodity_name, count(distinct country_code) as Total_Countries
from global_wfp_food_prices.wfp_food_prices
group by commodity_name
Having count(distinct country_code)>5
order by Total_Countries Desc;


# 5. Find the top 10 most frequently recorded commodities.​
select commodity_name, count(*) as Total_Records
from global_wfp_food_prices.wfp_food_prices
group by commodity_name
order by Total_Records Desc
LIMIT 10;


# 6. Show average price_usd per commodity.​
select commodity_name, avg(price_usd) as avg_price_usd
from global_wfp_food_prices.wfp_food_prices
group by commodity_name
order by avg_price_usd Desc;



# 7. Find the country with the highest average food price.​
Select country_code,
avg(price_usd) as avg_price_usd
from global_wfp_food_prices.wfp_food_prices
group by country_code
order by avg_price_usd Desc
LIMIT 1;

# 8. Identify commodities where price_usd is NULL or zero.​
select commodity_name#, avg(price_usd) as avg_price_usd
from global_wfp_food_prices.wfp_food_prices
where price_usd IS NULL OR price_usd=0
group by commodity_name;


# 9. Find markets that have only one commodity listed.​
select market, count(Distinct commodity) as Total_Commodities
from global_wfp_food_prices.wfp_food_prices
group by market
Having count(Distinct commodity)=1;

# 10. Count records per year.​
select Year(Date) as'Year', count(*) as Total_Records
from global_wfp_food_prices.wfp_food_prices
group by  Year(Date);


# 11. Compute average, minimum, and maximum price per commodity.​
select commodity_name, round(avg(price_usd),2) as avg_price_usd,min(price_usd) as min_price,max(price_usd) as max_price
from global_wfp_food_prices.wfp_food_prices
WHERE price_usd IS NOT NULL AND price_usd > 0
group by commodity_name;


# 12. Compare average prices of the same commodity across countries.
select commodity_name,country_code, round(avg(price_usd),2) as avg_price_usd
from global_wfp_food_prices.wfp_food_prices
group by commodity_name,country_code
order by commodity_name,country_code;

# 13. Identify the most expensive commodity per country.​
With expensive_commodity as (
select country_code,commodity_name,round(avg(price_usd),2) as avg_price_usd,
dense_rank() over (Partition by country_code order by round(avg(price_usd),2) desc) as rnk
from global_wfp_food_prices.wfp_food_prices
group by country_code,commodity_name
)
select country_code,commodity_name,avg_price_usd
from expensive_commodity
where rnk=1;

# 14. Find the cheapest market for each commodity.​
With cheapest_market as (
select commodity_name,market,avg(price_usd) as avg_price_usd,
dense_rank() over (Partition by commodity_name order by avg(price_usd) asc) as rnk
from global_wfp_food_prices.wfp_food_prices
group by commodity_name,market
having avg(price_usd) is not null and  avg(price_usd)>0
)
select commodity_name,market,round(avg_price_usd,3) as cheapest_avg_price_usd
from cheapest_market
where rnk=1;


# 15. Rank countries by overall average food price.​
select country_code, round(avg(price_usd),2) as avg_price_usd, 
dense_rank() over (order by round(avg(price_usd),2) desc) as "rank"
from global_wfp_food_prices.wfp_food_prices
group by country_code;


# 16. Show year-wise average food prices globally.​
select Year(Date) as'Year', round(avg(price_usd),2) as avg_price_usd
from global_wfp_food_prices.wfp_food_prices
group by  Year(Date);

 
# 17. Identify the top 3 commodities contributing to high prices in each country.​
With top_commodities as (
select country_code,commodity_name,avg(price_usd) as avg_price_usd,
dense_rank() over (Partition by country_code order by avg(price_usd) desc) as rnk
from global_wfp_food_prices.wfp_food_prices
where price_usd is not null and price_usd>0
group by country_code,commodity_name
)
select country_code,commodity_name,round(avg_price_usd,3) as avg_price_usd,rnk
from top_commodities
where rnk<=3;

# 18. Find commodities with price ranges (max − min) greater than X.​
select commodity_name, min(price_usd) as min_price,max(price_usd) as max_price,(MAX(price_usd) - MIN(price_usd)) as price_range
from global_wfp_food_prices.wfp_food_prices
group by  commodity_name
HAVING (MAX(price_usd) - MIN(price_usd)) > 0.5 * AVG(price_usd);

# 19. Compare local currency prices vs USD prices (consistency check).​
select country_code, currency,round(avg(local_price/price_usd),2) as implied_fx_rate 
from global_wfp_food_prices.wfp_food_prices
where (price_usd is not null and price_usd>0) and 
  ( local_price is not null and local_price>0)
group by country_code,currency;

# 20. Identify markets where prices are consistently above country average.​
WITH country_avg AS (
    SELECT 
        country_code,
        AVG(price_usd) AS country_avg_price
    FROM global_wfp_food_prices.wfp_food_prices
    WHERE price_usd IS NOT NULL 
      AND price_usd > 0
    GROUP BY country_code
)
SELECT 
    gp.country_code,
    gp.market,
    ROUND(AVG(gp.price_usd), 2) AS market_avg_price,
    ROUND(ca.country_avg_price, 2) AS country_avg_price
FROM global_wfp_food_prices.wfp_food_prices gp
JOIN country_avg ca 
  ON gp.country_code = ca.country_code
WHERE gp.price_usd IS NOT NULL 
  AND gp.price_usd > 0
GROUP BY gp.country_code, gp.market, ca.country_avg_price
HAVING AVG(gp.price_usd) > ca.country_avg_price
ORDER BY gp.country_code, market_avg_price DESC;


# 21. Calculate Year-over-Year (YoY) price change per commodity.​
with yoy_change as (
 SELECT commodity_name,year(date) as `year`,round(avg(price_usd),3) as avg_price_usd
    FROM global_wfp_food_prices.wfp_food_prices
    WHERE price_usd IS NOT NULL 
      AND price_usd > 0
    GROUP BY commodity_name,year(date)
)
select commodity_name,`year`,avg_price_usd,
round((avg_price_usd-LAG(avg_price_usd) over(partition by commodity_name order by `year`))*100.0
/LAG(avg_price_usd) over(partition by commodity_name order by `year`),2) as percentage_change
FROM yoy_change 
order by commodity_name,`year`;

# 22. Identify the year with the highest average inflation globally.​
with yoy_change as (
 SELECT year(date) as `year`,round(avg(price_usd),3) as avg_price_usd
    FROM global_wfp_food_prices.wfp_food_prices
    WHERE price_usd IS NOT NULL 
      AND price_usd > 0
    GROUP BY year(date)
),
per_inflation as(
select `year`,avg_price_usd,
round((avg_price_usd-LAG(avg_price_usd) over(order by `year`))*100.0
/LAG(avg_price_usd) over(order by `year`),2) as percentage_change
FROM yoy_change 
order by `year`)

select `year`,percentage_change
from per_inflation 
where percentage_change=(select max(percentage_change) from per_inflation);


# 23. Find commodities with continuous price increase for 3+ years.​
with cte as (
select commodity_name,year(date) as `year`,avg(price_usd) as avg_price_usd
from global_wfp_food_prices.wfp_food_prices
group by commodity_name,year(date)
order by commodity_name,year(date)
),
cte2 as (
select commodity_name,avg_price_usd,LAG(avg_price_usd,1) over (partition by commodity_name order by `year`) as prev_price,
LAG(avg_price_usd,2) over (partition by commodity_name order by `year`) as prev1_price,
LAG(avg_price_usd,3) over (partition by commodity_name order by `year`) as prev2_price
from cte

)
select distinct commodity_name
from cte2
where avg_price_usd >prev_price and prev_price >prev1_price and prev1_price >prev2_price
and avg_price_usd is not null and prev_price is not null and prev1_price is not null and  prev2_price is not null ;


# 24. Compute Month-over-Month (MoM) price change.​
with cte as (
select  DATE_FORMAT(date, '%Y-%m') AS  `year_month`,round(avg(price_usd),2) as avg_price_usd
from global_wfp_food_prices.wfp_food_prices
group by DATE_FORMAT(date, '%Y-%m')

)
select `year_month`,avg_price_usd,
round(
(avg_price_usd-LAG(avg_price_usd) over (Order by `year_month`))*100.0/LAG(avg_price_usd) over (Order by `year_month`)
,2) as per_change
from cte
order by `year_month`;


# 25. Detect price spikes (>25% increase) between consecutive periods.​
with cte as (
select  commodity_name,DATE_FORMAT(date, '%Y-%m') AS  `year_month`,round(avg(price_usd),2) as avg_price_usd
from global_wfp_food_prices.wfp_food_prices
group by commodity_name,DATE_FORMAT(date, '%Y-%m')
),
price_change as (
select commodity_name,`year_month`,avg_price_usd,LAG(avg_price_usd) over (Partition By commodity_name Order by `year_month`) as prev_avg_price_usd,
round(
(avg_price_usd-LAG(avg_price_usd) over (Partition By commodity_name Order by `year_month`))*100.0/LAG(avg_price_usd) over (Partition By commodity_name Order by `year_month`)
,2) as per_change
from cte
where avg_price_usd>0 and avg_price_usd is not null
order by `year_month`)
select * from
price_change
where per_change>25
order by commodity_name,`year_month`;

# 26. Identify countries where food prices doubled over the dataset period.​
with cte as 
(select country_code,year(date) as `year`,round(avg(price_usd),2) as avg_price_usd
from global_wfp_food_prices.wfp_food_prices
group by country_code,year(date)
),
min_max_price as(
select country_code,min(year(date)) as start_year,max(year(date)) as latest_year
from global_wfp_food_prices.wfp_food_prices
group by country_code),
price_diff as (
select mm1.country_code,mm1.start_year,c1.avg_price_usd as intial_year_price,mm1.latest_year,c2.avg_price_usd as latest_year_price
from min_max_price mm1 join cte c1 on mm1.country_code=c1.country_code and mm1.start_year=c1.year 
join cte c2 on mm1.country_code=c2.country_code  and mm1.latest_year=c2.year)
select country_code, round(intial_year_price,2) as intial_year_price,
round(latest_year_price,2) as latest_year_price,
round(latest_year_price/intial_year_price,2) as price_multiple
from price_diff
where latest_year_price>=2*intial_year_price
order by price_multiple desc;




# 27. Rank commodities by long-term price growth.​
with cte as 
(select commodity_name,year(date) as `year`,round(avg(price_usd),2) as avg_price_usd
from global_wfp_food_prices.wfp_food_prices
group by commodity_name,year(date)
),
min_max_price as(
select commodity_name,min(year(date)) as start_year,max(year(date)) as latest_year
from global_wfp_food_prices.wfp_food_prices
group by commodity_name),
price_diff as (
select mm1.commodity_name,mm1.start_year,c1.avg_price_usd as intial_year_price,mm1.latest_year,c2.avg_price_usd as latest_year_price,
round((c2.avg_price_usd-c1.avg_price_usd )*100.0/c1.avg_price_usd ,2) as growth_rate
from min_max_price mm1 join cte c1 on mm1.commodity_name=c1.commodity_name and mm1.start_year=c1.year 
join cte c2 on mm1.commodity_name=c2.commodity_name  and mm1.latest_year=c2.year)
select commodity_name, round(intial_year_price,2) as intial_year_price,
round(latest_year_price,2) as latest_year_price,
growth_rate, dense_rank() over (order by growth_rate desc)
from price_diff
where intial_year_price>0
;

# 28. Find volatile commodities using standard deviation.​
select commodity_name , round(stddev(price_usd),2) as volatility
from global_wfp_food_prices.wfp_food_prices
where price_usd>0 and price_usd is not null
group by commodity_name
order by volatility desc;

# 29. Compare inflation trends between two selected countries.​
WITH yearly_prices AS (
    SELECT
        country_code,
        YEAR(date) AS year,
        AVG(price_usd) AS avg_price_usd
    FROM global_wfp_food_prices.wfp_food_prices
    WHERE price_usd IS NOT NULL
      AND price_usd > 0
      AND country_code IN ('IND', 'CHN','JPN','RUS')
    GROUP BY country_code, YEAR(date)
),
inflation_trend AS (
    SELECT   country_code,year,avg_price_usd,
    ROUND((avg_price_usd - LAG(avg_price_usd) OVER (PARTITION BY country_code ORDER BY year)) * 100.0
    /LAG(avg_price_usd) OVER (PARTITION BY country_code ORDER BY year),2) AS yoy_inflation
    FROM yearly_prices
)
SELECT
    country_code,
    year,
    ROUND(avg_price_usd, 2) AS avg_price_usd,
    yoy_inflation
FROM inflation_trend
ORDER BY country_code, year;


# 30. Identify years of price instability during crises (e.g., 2008, 2020).​
WITH yearly_prices AS(select year(date) as `year`, avg(price_usd) as avg_price_usd
FROM global_wfp_food_prices.wfp_food_prices
group by year(date)
order by year(date)
),
yoy_inflation as (
select `year`,avg_price_usd,
round((avg_price_usd-LAG(avg_price_usd) over(Order by `year`))*100.0/LAG(avg_price_usd) over(Order by `year`) ,2) as yoy_inflation
from yearly_prices
)
select `year`,round(avg_price_usd,2) as avg_price_usd,
yoy_inflation,
CASE
when `year` in (2008,2020) then 'Known Crisis Year'
When ABS(yoy_inflation) >= 10 THEN 'High Price Instability'
ELSE 'Normal'
end as instability_flag
from yoy_inflation
WHERE year >= 2000
ORDER BY `year`;


# 31. Use LAG() to compare current vs previous year prices.​
with prev_changes as (
select year(date) as `year`,round(avg(price_usd),2) as avg_price_usd
from global_wfp_food_prices.wfp_food_prices
group by `year` 
order by `year`)
select `year`,avg_price_usd, LAG(avg_price_usd) over (order by `year`) as prev_price
from prev_changes
order by `year`;



# 32. Calculate rolling 3-year average price per commodity.​
with rolling_avg_price as (
select commodity_name,year(date) as `year`,avg(price_usd) as avg_price_usd
from global_wfp_food_prices.wfp_food_prices
group by commodity_name,year(date) 
order by commodity_name,year(date))
 select commodity_name,`year`,round(avg_price_usd,2) as avg_price_usd,
 round(Avg(avg_price_usd) over(Partition by commodity_name order by `year` Rows Between 2 preceding and current row),2) as '3_year_avg_price'
 from rolling_avg_price
 order by commodity_name,`year`;

# 33. Rank commodities within each country by price.​
with cte as(select country_code,commodity_name, avg(price_usd) as avg_price_usd
from global_wfp_food_prices.wfp_food_prices
where price_usd>0 and price_usd is not null
group by country_code,commodity_name)
,
rankings as(select country_code,commodity_name, avg_price_usd,
dense_rank() over (Partition by country_code order by avg_price_usd desc) as rnk
from cte)
select country_code,commodity_name, round(avg_price_usd,2), rnk
from rankings
where rnk<=10
order by country_code,rnk
;

# 34. Identify consecutive inflation years using window functions.​
with cte as (
select year(date) as `year`,round(avg(price_usd),2) as avg_price_usd
from global_wfp_food_prices.wfp_food_prices
where price_usd>0 and price_usd is not null
group by `year`),
prev_prices as(
select `year`,avg_price_usd,
LAG(avg_price_usd,1) over (Order by `year`) as prev_year_price_1,
LAG(`year`,1) over (Order by `year`) as prev_year_1,
LAG(avg_price_usd,2) over (Order by `year`) as prev_year_price_2,
LAG(`year`,2) over (Order by `year`) prev_year_2
from cte)
select `year`,avg_price_usd,
prev_year_1,prev_year_price_1,
prev_year_2,prev_year_price_2
from prev_prices
where  avg_price_usd>prev_year_price_1 and prev_year_price_1 >prev_year_price_2 
and  `year` = prev_year_1 + 1  and prev_year_1 = prev_year_2 + 1
order by `year`;


# 35. Find markets that show abnormal deviation from national trends.​
with country_stats as (
select country_code, avg(price_usd) as country_avg_price, stddev(price_usd) as country_price_std
from global_wfp_food_prices.wfp_food_prices
WHERE price_usd IS NOT NULL AND price_usd > 0
GROUP BY country_code
),
market_stats AS (
    SELECT
        country_code,
        market,
        AVG(price_usd) AS market_avg_price
    FROM global_wfp_food_prices.wfp_food_prices
    WHERE price_usd IS NOT NULL
      AND price_usd > 0
    GROUP BY country_code, market
),
market_deviation AS (
    SELECT
        m.country_code,
        m.market,
        ROUND(m.market_avg_price, 2) AS market_avg_price,
        ROUND(c.country_avg_price, 2) AS country_avg_price,
        ROUND(c.country_price_std, 2) AS country_price_std,
        ROUND(
            (m.market_avg_price - c.country_avg_price) / c.country_price_std,
            2
        ) AS deviation_zscore
    FROM market_stats m
    JOIN country_stats c
        ON m.country_code = c.country_code
)
SELECT *
FROM market_deviation
WHERE ABS(deviation_zscore) >= 2
ORDER BY ABS(deviation_zscore) DESC;


# 36. Detect structural breaks (sudden regime shifts in pricing).​
with cte as (select year(date) as `year`,avg(price_usd) as avg_price_usd
FROM global_wfp_food_prices.wfp_food_prices
where price_usd>0 and price_usd is not null
group by  `year`
order by  `year`),
cte2 as (
select `year`,avg_price_usd,
avg(avg_price_usd) over (Order by `year` rows between 3 preceding and 1 preceding) as prev_3_year_price
from cte
)
select `year`,round(avg_price_usd,2) as avg_price_usd,round(prev_3_year_price,2) as prev_3_year_price ,
round((avg_price_usd-prev_3_year_price)*100.0/prev_3_year_price,2) as percentage_inflation
from cte2
where prev_3_year_price IS NOT NULL and (avg_price_usd-prev_3_year_price)/prev_3_year_price >=0.25
order by `year`;


# 37. Find the top 5 worst inflation events by magnitude.​
with cte as (
select year(date) as `year`, avg(price_usd) as avg_price_usd
FROM global_wfp_food_prices.wfp_food_prices
where price_usd>0 and price_usd is not null
group by  `year`
order by  `year`),
yoy_inflate as (
select `year`, avg_price_usd,
round((avg_price_usd-LAG(avg_price_usd) over (order by `year` DESC))*100.0/LAG(avg_price_usd) over (order by `year` DESC),2) as price_inflation
from cte
ORDER BY `year`

)
select `year`,round(avg_price_usd,2) as avg_price_usd,price_inflation,
abs(price_inflation) as inflation_magnitude,
dense_rank() over(order by abs(price_inflation) desc) as rnk
from yoy_inflate
WHERE price_inflation IS NOT NULL
ORDER BY inflation_magnitude DESC
LIMIT 5;


# 39. Create a price index per country using a base year.​
WITH yearly_prices AS (
    SELECT
        country_code,
        YEAR(date) AS year,
        AVG(price_usd) AS avg_price_usd
    FROM global_wfp_food_prices.wfp_food_prices
    WHERE price_usd IS NOT NULL
      AND price_usd > 0
    GROUP BY country_code, YEAR(date)
),
base_year_prices AS (
    SELECT
        country_code,
        avg_price_usd AS base_price
    FROM yearly_prices
    WHERE year = 2000
),
price_index AS (
    SELECT
        y.country_code,
        y.year,
        y.avg_price_usd,
        b.base_price,
        ROUND((y.avg_price_usd / b.base_price) * 100, 2) AS price_index
    FROM yearly_prices y
    JOIN base_year_prices b
        ON y.country_code = b.country_code
)
SELECT
    country_code,
    year,
    ROUND(avg_price_usd, 2) AS avg_price_usd,
    price_index
FROM price_index
where price_index>100
ORDER BY country_code, year;


# 40. Flag commodities with high price volatility & upward trend.​
WITH volatility AS (
    SELECT
        commodity_name,
        STDDEV(price_usd) AS price_volatility
    FROM global_wfp_food_prices.wfp_food_prices
    WHERE price_usd IS NOT NULL AND price_usd > 0
    GROUP BY commodity_name
),

yearly_prices AS (
    SELECT
        commodity_name,
        YEAR(date) AS year,
        AVG(price_usd) AS avg_price_usd
    FROM global_wfp_food_prices.wfp_food_prices
    WHERE price_usd IS NOT NULL AND price_usd > 0
    GROUP BY commodity_name, YEAR(date)
),

min_max_year AS (
    SELECT
        commodity_name,
        MIN(year) AS min_year,
        MAX(year) AS max_year
    FROM yearly_prices
    GROUP BY commodity_name
),

min_max_price AS (
    SELECT
        mm.commodity_name,
        mm.min_year,
        y1.avg_price_usd AS initial_year_price,
        mm.max_year,
        y2.avg_price_usd AS last_year_price
    FROM min_max_year mm
    JOIN yearly_prices y1
        ON mm.commodity_name = y1.commodity_name
       AND mm.min_year = y1.year
    JOIN yearly_prices y2
        ON mm.commodity_name = y2.commodity_name
       AND mm.max_year = y2.year
),

volatility_threshold AS (
    SELECT AVG(price_volatility) AS avg_volatility
    FROM volatility
)

SELECT
    v.commodity_name,
    ROUND(v.price_volatility, 2) AS price_volatility,
    m.min_year,
    m.max_year,
    ROUND(
        (m.last_year_price - m.initial_year_price) * 100.0
        / m.initial_year_price,
        2
    ) AS price_inflation
FROM volatility v
JOIN min_max_price m
    ON v.commodity_name = m.commodity_name
CROSS JOIN volatility_threshold vt
WHERE v.price_volatility > vt.avg_volatility   -- HIGH volatility
  AND m.last_year_price > m.initial_year_price -- UPWARD trend
ORDER BY price_volatility DESC, price_inflation DESC
LIMIT 10;



# 41. If the government can subsidize only one commodity, which one shows the steepest long-term price rise?​
WITH yearly_prices AS (
    SELECT
        commodity_name,
        YEAR(date) AS year,
        AVG(price_usd) AS avg_price_usd
    FROM global_wfp_food_prices.wfp_food_prices
    WHERE price_usd IS NOT NULL
      AND price_usd > 0
    GROUP BY commodity_name, YEAR(date)
),
min_max_year AS (
    SELECT
        commodity_name,
        MIN(year) AS start_year,
        MAX(year) AS end_year
    FROM yearly_prices
    GROUP BY commodity_name
),
price_growth AS (
    SELECT
        mm.commodity_name,
        mm.start_year,
        mm.end_year,
        y1.avg_price_usd AS start_price,
        y2.avg_price_usd AS end_price,
        (y2.avg_price_usd - y1.avg_price_usd) * 100.0 / y1.avg_price_usd AS growth_pct
    FROM min_max_year mm
    JOIN yearly_prices y1
        ON mm.commodity_name = y1.commodity_name
       AND mm.start_year = y1.year
    JOIN yearly_prices y2
        ON mm.commodity_name = y2.commodity_name
       AND mm.end_year = y2.year
)
SELECT
    commodity_name,
    ROUND(start_price, 2) AS start_price,
    ROUND(end_price, 2) AS end_price,
    ROUND(growth_pct, 2) AS long_term_price_rise_pct
FROM price_growth
WHERE start_price > 0
ORDER BY growth_pct DESC
LIMIT 1;

# 42. Which countries are at highest food security risk based on inflation trends?​
WITH yearly_prices AS (
    SELECT
        country_code,
        YEAR(date) AS year,
        AVG(price_usd) AS avg_price_usd
    FROM global_wfp_food_prices.wfp_food_prices
    WHERE price_usd IS NOT NULL
      AND price_usd > 0
    GROUP BY country_code, YEAR(date)
),
inflation_calc AS (
    SELECT
        country_code,
        year,
        ROUND(
            (avg_price_usd - LAG(avg_price_usd) OVER (
                PARTITION BY country_code 
                ORDER BY year
            )) * 100.0
            / LAG(avg_price_usd) OVER (
                PARTITION BY country_code 
                ORDER BY year
            ),
            2
        ) AS yoy_inflation
    FROM yearly_prices
),
country_inflation_risk AS (
    SELECT
        country_code,
        ROUND(AVG(yoy_inflation), 2) AS avg_inflation,
        ROUND(STDDEV(yoy_inflation), 2) AS inflation_volatility,
        COUNT(yoy_inflation) AS inflation_years
    FROM inflation_calc
    WHERE yoy_inflation IS NOT NULL
    GROUP BY country_code
)
SELECT
    country_code,
    avg_inflation,
    inflation_volatility,
    inflation_years,
    DENSE_RANK() OVER (
        ORDER BY avg_inflation DESC, inflation_volatility DESC
    ) AS risk_rank
FROM country_inflation_risk
WHERE inflation_years >= 3
ORDER BY risk_rank
LIMIT 10;














































