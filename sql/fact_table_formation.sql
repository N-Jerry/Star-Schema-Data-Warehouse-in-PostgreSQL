-- DATA CLEANING AND TRANSFORMATION

CREATE TABLE fact_financial AS
WITH initial_fact AS (
	SELECT id, segment, country, product, discount_band, units_sold,
		CASE WHEN trim(regexp_replace(manufacturing_price, '[$,-]', '', 'g')) ~ '^\d+(\.\d+)?$'
			THEN regexp_replace(manufacturing_price, '[$,-]', '', 'g')::NUMERIC
			ELSE 0
		END AS manufacturing_price,
		CASE WHEN trim(regexp_replace(sale_price, '[$,-]', '', 'g')) ~ '^\d+(\.\d+)?$'
			THEN regexp_replace(sale_price, '[$,-]', '', 'g')::NUMERIC
			ELSE 0
		END AS sale_price,
		CASE WHEN trim(regexp_replace(gross_sales, '[$,-]', '', 'g')) ~ '^\d+(\.\d+)?$'
			THEN regexp_replace(gross_sales, '[$,-]', '', 'g')::NUMERIC
			ELSE 0
		END AS gross_sales,
		CASE WHEN trim(regexp_replace(discounts, '[$,-]', '', 'g')) ~ '^\d+(\.\d+)?$'
			THEN regexp_replace(discounts, '[$,-]', '', 'g')::NUMERIC
			ELSE 0
		END AS discounts,
		CASE WHEN trim(regexp_replace(sales, '[$,-]', '', 'g')) ~ '^\d+(\.\d+)?$'
			THEN regexp_replace(sales, '[$,-]', '', 'g')::NUMERIC
			ELSE 0
		END AS sales,
		CASE WHEN trim(regexp_replace(cogs, '[$,-]', '', 'g')) ~ '^\d+(\.\d+)?$'
			THEN regexp_replace(cogs, '[$,-]', '', 'g')::NUMERIC
			ELSE 0
		END AS cogs,
		CASE WHEN trim(regexp_replace(profit, '[$,-]', '', 'g')) ~ '^\d+(\.\d+)?$'
			THEN regexp_replace(profit, '[$,-]', '', 'g')::NUMERIC
			ELSE 0
		END AS profit,
		order_date, month_number, month_name, year
	FROM financial_data
),
-- FOR THE JOINS, We need to join the tables on step at at time so all key columns in the DIM tables enter the fact
-- Notice here that we use USING() instead of ON and there's no need to prefix ambigous columns like country, segment, product, discount_band
-- USING() combines both columns into one so we don't need to prefix the join columns by it's table name
country_join AS (
	SELECT 
	    id, segment, country, product, discount_band, units_sold, manufacturing_price, sale_price, gross_sales,
		discounts, sales, cogs, profit, order_date, countries.country_id
	FROM initial_fact
	JOIN countries USING(country)
),
segment_join AS (
	SELECT 
	    id, segment, country, product, discount_band, units_sold, manufacturing_price, sale_price, gross_sales,
		discounts, sales, cogs, profit, order_date, country_id, segments.segment_id
	FROM country_join
	JOIN segments USING(segment)
),
product_join AS (
	SELECT 
	    id, segment, country, product, discount_band, units_sold, manufacturing_price, sale_price, gross_sales,
		discounts, sales, cogs, profit, order_date, country_id, segment_id, products.product_id
	FROM segment_join
	JOIN products USING(product)
),
-- Now for the discount_band join
final_join AS (
	SELECT 
	    id, segment, country, product, discount_band, units_sold, manufacturing_price, sale_price, gross_sales,
		discounts, sales, cogs, profit, order_date, country_id, segment_id, product_id, discount_bands.discount_band_id
	FROM product_join
	JOIN discount_bands USING(discount_band)
)
SELECT *
FROM final_join

-- Now for adding FOREIGN KEY CONSTRAINTS

ALTER TABLE fact_financial
    ADD FOREIGN KEY (country_id) REFERENCES countries(country_id),
    ADD FOREIGN KEY (segment_id) REFERENCES segments(segment_id),
    ADD FOREIGN KEY (product_id) REFERENCES products(product_id),
    ADD FOREIGN KEY (discount_band_id) REFERENCES discount_bands(discount_band_id),
    ADD FOREIGN KEY (order_date) REFERENCES date_table(full_date);

-- DROP Unwanted columns from our fact table
ALTER TABLE fact_financial
    DROP COLUMN country,
    DROP COLUMN segment,
    DROP COLUMN product,
    DROP COLUMN discount_band;

