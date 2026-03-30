-- FORMATION OF DIM TABLES

CREATE TABLE segments AS
SELECT DISTINCT segment FROM financial_data;

CREATE TABLE countries AS
SELECT DISTINCT country FROM financial_data;

CREATE TABLE products AS
SELECT DISTINCT product FROM financial_data;

CREATE TABLE discount_bands AS
SELECT DISTINCT discount_band FROM financial_data;


CREATE TABLE date_table AS
WITH bounds AS (
    SELECT 
        date_trunc('year', MIN(order_date))::date AS start_date,
        (date_trunc('year', MAX(order_date)) + interval '1 year - 1 day')::date AS end_date
    FROM financial_data
)
SELECT d::date AS full_date,
       EXTRACT(YEAR FROM d) AS year,
	   'Q' || EXTRACT(QUARTER FROM d) AS quarter,
       EXTRACT(MONTH FROM d) AS month_number,
       TO_CHAR(d, 'Month') AS month_name,
       EXTRACT(DAY FROM d) AS month_day,
       EXTRACT(DOW FROM d) AS weekday,
       TO_CHAR(d, 'Day') AS weekday_name
FROM bounds, generate_series(bounds.start_date, bounds.end_date, interval '1 day') AS g(d);

SELECT * FROM date_table LIMIT 10;

-- ADDING PRIMARY KEYS TO TABLE
ALTER TABLE countries
ADD COLUMN country_id SERIAL PRIMARY KEY;

ALTER TABLE segments
ADD COLUMN segment_id SERIAL PRIMARY KEY;

ALTER TABLE discount_bands
ADD COLUMN discount_band_id SERIAL PRIMARY KEY;

ALTER TABLE products
ADD COLUMN product_id SERIAL PRIMARY KEY;

ALTER TABLE date_table
ADD PRIMARY KEY (full_date);
