-- EDA Analysis.
-- Business Performance
-- Total sales country
SELECT country, TO_CHAR(SUM(sales), 'FM999,999,999,999.99') total_sales
FROM fact_financial
JOIN countries USING(country_id)
GROUP BY country
ORDER BY total_sales DESC;

-- Total sales per product
SELECT product, TO_CHAR(SUM(sales), 'FM999,999,999,999.99') total_sales
FROM fact_financial
JOIN products USING(product_id)
GROUP BY product
ORDER BY total_sales DESC;

-- Sales per segment
SELECT segment, TO_CHAR(SUM(sales), 'FM999,999,999,999.99') total_sales
FROM fact_financial
JOIN segments USING(segment_id)
GROUP BY segment
ORDER BY total_sales DESC;


-- Profitability Analysis
-- Profit Margin per Product
SELECT product, ROUND(SUM(profit) *100/SUM(sales),2) || '%' profit_margin
FROM fact_financial
JOIN products USING(product_id)
GROUP BY product
ORDER BY profit_margin DESC;

-- Most Profitable Countries
SELECT country, TO_CHAR(SUM(profit), 'FM999,999,999,999.99') total_profit
FROM fact_financial
JOIN countries USING(country_id)
GROUP BY country
ORDER BY total_profit DESC;

-- Below Average profit Segments
WITH all_seg_avg AS (
	SELECT segment, AVG(profit) avg_profit
	FROM fact_financial
	JOIN segments USING(segment_id)
	GROUP BY segment
	ORDER BY avg_profit DESC
)
SELECT segment, TO_CHAR(avg_profit, 'FM999,999,999,999.99')
FROM all_seg_avg
WHERE avg_profit < (SELECT AVG(avg_profit) FROM all_seg_avg)

-- Discount impact on profits
SELECT discount_band, TO_CHAR(SUM(profit), 'FM999,999,999,999.99') total_profit
FROM fact_financial
JOIN discount_bands USING(discount_band_id)
GROUP BY discount_band
ORDER BY total_profit DESC;
