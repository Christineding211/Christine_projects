
-- Find the number of unique companies and their total carbon footprint PCF for each industry group, filtering for the most recent year in the database. 
-- The query should return three columns: industry_group, num_companies, and total_industry_footprint, with the last column being rounded to one decimal place. 
-- The results should be sorted by total_industry_footprint from highest to lowest values.

SELECT industry_group,
    COUNT(DISTINCT company) AS num_companies,
    ROUND(SUM(carbon_footprint_pcf), 1) AS total_industry_footprint
FROM product_emissions
WHERE year = (SELECT MAX(year) FROM product_emissions)
GROUP BY industry_group
ORDER BY total_industry_footprint DESC;




-- Return industry_group and a rounded total of carbon_footprint_pcf, aliased as total_industry_footprint
-- Limit to data for 2017 and order by total_industry_footprint

SELECT industry_group, ROUND(SUM(carbon_footprint_pcf),2) AS total_industry_footprint 
FROM public.product_emissions
GROUP BY industry_group , year -- we need to tell SQL how to sum
HAVING year = 2017
ORDER BY SUM(carbon_footprint_pcf) DESC;

-- Create a plotly bar chart of the country distribution for companies in our dataset

import plotly.express as px(python)

SELECT country, SUM(carbon_footprint_pcf) AS total_country_footprint
FROM public.product_emissions
GROUP BY country;

px.bar(total_emission , x = 'country',y ='total_country_footprint')