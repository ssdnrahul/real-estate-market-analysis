CREATE DATABASE IF NOT EXISTS real_estate;
USE real_estate;


-- ============================================================
-- REAL ESTATE MARKET ANALYSIS PROJECT
-- Stage 1: Data Exploration & Data Quality Assessment
-- ============================================================

SHOW TABLES;

-- Dataset Overview
-- market_trends           : Market Indicators & Economic Trends
-- properties_transactions : Property Listings & Transactions

-- ============================================================
-- Q1. Total Records in Each Table
-- Objective:
-- Understand dataset size before starting analysis.
-- ============================================================

SELECT COUNT(*) AS total_records
FROM market;

SELECT COUNT(*) AS total_records
FROM properties;

-- Business Insight:
-- 120 market trend records, and 20,000 property transactions,
-- providing sufficient data for reliable market analysis.



-- ============================================================
-- Q2. Data Validation: Invalid Listing Prices
-- Objective:
-- Identify properties with zero or negative prices.
-- ============================================================

SELECT Property_ID,
       Listing_Price
FROM properties
WHERE Listing_Price <= 0;

-- Business Insight:
-- No properties were found with zero or negative listing prices,
-- indicating strong pricing data quality and consistency.



-- ============================================================
-- Q3. Listing Price Range Analysis
-- Objective:
-- Understand the minimum and maximum listing prices.
-- ============================================================

SELECT MIN(Listing_Price) AS Min_Listing_Price,
       MAX(Listing_Price) AS Max_Listing_Price
FROM properties;

-- Business Insight:
-- Property listing prices range from approximately
-- $100K to $2M, reflecting a diverse mix of housing
-- segments from affordable to premium properties.



-- ============================================================
-- Q4. Duplicate Transaction Check
-- Objective:
-- Identify duplicate property transactions.
-- ============================================================

SELECT Property_ID,
       Listing_Price,
       Neighborhood,
       COUNT(*) AS duplicate_count
FROM properties
GROUP BY Property_ID,
         Listing_Price,
         Neighborhood
HAVING COUNT(*) > 1;

-- Business Insight:
-- No duplicate transactions were identified,

-- ============================================================
-- Q5. Property Size Validation
-- Objective:
-- Analyze property size distribution and detect outliers.
-- ============================================================

SELECT MIN(Size_SqFt) AS Min_Size,
       MAX(Size_SqFt) AS Max_Size,
       ROUND(AVG(Size_SqFt),2) AS Avg_Size
FROM properties;

SELECT *
FROM properties
WHERE Size_SqFt < 200;

-- Business Insight:
-- Property sizes range from standard residential units
-- to large premium properties.
-- No unrealistic property sizes were identified,
-- indicating high-quality size measurements.

-- ============================================================
-- Stage 2: Property Pricing Analysis
-- ============================================================

-- ============================================================
-- Q1. How Do Property Prices Vary by Property Type?
--
-- Objective:
-- Compare average listing prices across property categories
-- to identify premium and affordable housing segments.
-- ============================================================

SELECT Type,
       ROUND(AVG(Listing_Price),2) AS Avg_Listing_Price
FROM properties
GROUP BY Type
ORDER BY Avg_Listing_Price DESC;

SELECT
    Type,
    COUNT(*) AS Total_Listings,
    ROUND(AVG(Listing_Price),2) AS Avg_Listing_Price,
    ROUND(MIN(Listing_Price),2) AS Min_Price,
    ROUND(MAX(Listing_Price),2) AS Max_Price
FROM properties
GROUP BY Type
ORDER BY Avg_Listing_Price DESC;

-- ============================================================
-- BUSINESS INSIGHTS
-- ============================================================

/*
• Townhouses recorded the highest average listing prices,
  making them the premium property category in the dataset.
• Houses showed the lowest average listing prices,
  positioning them as relatively affordable options.
*/

-- ============================================================
-- Q2. Which Property Types Are Most Frequently Listed?
--
-- Objective:
-- Identify inventory distribution and market availability.
-- ============================================================

SELECT Type, City, COUNT(*) AS Listings_Count
FROM Properties_transactions
GROUP BY Type, City
ORDER BY Listings_Count DESC;

SELECT
    Type,
    COUNT(*) AS Total_Listings
FROM properties
GROUP BY Type
ORDER BY Total_Listings DESC;

-- ============================================================
-- BUSINESS INSIGHTS
-- ============================================================

/*
• Apartments emerged as the most frequently listed
  property category across multiple cities.
• Seattle recorded the highest listing activity,
  indicating strong housing market participation.
• Chicago, Miami, Los Angeles, and Seattle maintained
  consistently high listing volumes across multiple
  property categories.
• Properties classified as 'Other' contributed the
  smallest share of inventory, indicating that most
  market activity is concentrated within Apartments,
  Houses, Condos, and Townhouses.
*/

-- ============================================================
-- Stage 3: Market Trends & Growth Analysis
-- ============================================================

-- ============================================================
-- Q1. Which Cities Have the Highest Average Home Prices?
--
-- Objective:
-- Identify premium housing markets based on
-- average home values.
-- ============================================================

SELECT City,
       ROUND(AVG(Avg_Home_Price),2) AS Avg_Home_Price
FROM market
GROUP BY City
ORDER BY Avg_Home_Price DESC;

-- ============================================================
-- BUSINESS INSIGHTS
-- ============================================================

/*
• San Francisco recorded the highest average home prices,
  making it the most premium housing market in the dataset.
• Miami ranked second, reflecting strong residential demand
  and sustained market appreciation.
• Los Angeles reported comparatively lower average home
  prices among the analyzed cities.
• Differences in home prices reflect varying demand,
  economic conditions, and housing supply levels.
*/

-- ============================================================
-- Q2. How Have Home Prices Changed Over Time?
--
-- Objective:
-- Measure year-over-year home price growth by city.
-- ============================================================

WITH ninjas AS (
SELECT City, Year, AVG(Avg_Home_Price) AS Avg_Price
FROM market
GROUP BY City, Year),
coding AS (SELECT City, Year, Avg_Price,
LAG(Avg_Price) OVER(PARTITION BY City ORDER BY Year) AS prev_price
FROM ninjas
)
SELECT City, Year, Avg_Price, prev_price,
ROUND(
((Avg_Price - prev_price) / prev_price) * 100,2) AS yoy_growth
FROM coding;

-- ============================================================
-- BUSINESS INSIGHTS
-- ============================================================

/*
• San Francisco demonstrated the strongest long-term
  property appreciation throughout the analysis period.
• Miami experienced a strong recovery following temporary
  declines in 2020 and 2021.
• Chicago displayed the highest volatility with multiple
  periods of negative growth.
• Los Angeles and Seattle recorded sharp price increases
  during 2022, indicating changing market conditions.
• New York maintained comparatively stable growth patterns.
*/

-- ============================================================
-- Q3. Which City Recorded the Highest Property Values
-- Each Year?
-- ============================================================

WITH ninjas AS (
SELECT Year, City, Avg_Home_Price,
ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Avg_Home_Price DESC) AS rn
FROM market
)

SELECT 'Highest Property Values' AS Property_Values,
Year, City
FROM ninjas
WHERE rn = 1;

-- ============================================================
-- BUSINESS INSIGHTS
-- ============================================================

/*
• Miami secured the highest property values in multiple
  years, demonstrating consistent market strength.
• San Francisco became the highest-valued market in 2021.
• Los Angeles achieved the highest property values in 2022.
*/

-- ============================================================
-- Q4. Which City Recorded the Lowest Property Values
-- Each Year?
-- ============================================================

WITH ninjas AS (
SELECT Year, City, Avg_Home_Price,
ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Avg_Home_Price) AS rn
FROM market
)

SELECT 'Lowest Property Values' AS Property_Values,
Year, City
FROM ninjas
WHERE rn = 1;

-- ============================================================
-- BUSINESS INSIGHTS
-- ============================================================

/*
• Los Angeles appeared most frequently among the
  lowest-valued markets during the study period.
• San Francisco moved from the lowest-valued market
  in 2019 to the highest-valued market in 2021.
*/


-- ============================================================
-- Stage 4: Demand, Affordability & Investor Analysis
-- ============================================================

-- ============================================================
-- Q1. Which Cities Exhibit the Strongest Housing Demand,
-- and What Are the Typical Home and Rental Prices?
--
-- Objective:
-- Identify high-demand housing markets and compare
-- average home and rental prices.
-- ============================================================

SELECT City,
       ROUND(AVG(Housing_Demand_Index),2) AS Highest_Demand_Index,
       ROUND(AVG(Avg_Home_Price),2) AS Avg_Typical_Home_Price,
       ROUND(AVG(Avg_Rent_Price),2) AS Avg_Typical_Rent_Price
FROM market
GROUP BY City
ORDER BY Highest_Demand_Index DESC;

-- ============================================================
-- BUSINESS INSIGHTS
-- ============================================================

/*
• San Francisco recorded the highest housing demand index,
  indicating strong buyer interest and market activity.
• Seattle demonstrated a balanced combination of demand
  and affordability, making it attractive for long-term buyers.
*/

-- ============================================================
-- Q3. Which Cities Attract the Highest Investor Activity?
--
-- Objective:
-- Rank cities based on investor participation.
-- ============================================================

WITH investor_activity AS (
SELECT City, ROUND(AVG(Investor_Activity_Score),2) AS Avg_Investor_Activity
FROM market
GROUP BY City
)

SELECT City, Avg_Investor_Activity,
DENSE_RANK() OVER (ORDER BY Avg_Investor_Activity DESC) AS Investor_Rank
FROM investor_activity;

-- ============================================================
-- BUSINESS INSIGHTS
-- ============================================================

/*
• Los Angeles and Chicago recorded the highest investor
  activity scores among all cities.
• Strong investor participation often reflects confidence
  in future property appreciation and rental income potential.
• Markets with high investor activity may experience
  accelerated growth due to increased capital inflows.
*/

-- ============================================================
-- Q4. Which Income Groups Face the Greatest Housing
-- Affordability Challenges?
--
-- Objective:
-- Evaluate affordability stress across income brackets.
-- ============================================================

WITH ninjas AS (
SELECT Income_Bracket,
       ROUND(AVG(Affordability_Price_to_Income_Ratio),2)
       AS Price_to_income_ratio
FROM market
GROUP BY Income_Bracket
)

SELECT Income_Bracket, Price_to_income_ratio,
CASE WHEN Price_To_Income_Ratio >= 6 THEN 'Severely Unaffordable'
WHEN Price_To_Income_Ratio >= 5 THEN 'Moderately Unaffordable'
WHEN Price_To_Income_Ratio >= 4 THEN 'Slightly Unaffordable'
ELSE 'Affordable' END AS Affordability_Stress
FROM ninjas
ORDER BY Price_To_Income_Ratio DESC;

-- ============================================================
-- BUSINESS INSIGHTS
-- ============================================================

/*
• Housing affordability challenges were observed across
  all income brackets.
• The $100K–$150K income segment experienced the highest
  affordability pressure.
• Affordability remains a key factor influencing future
  housing demand and market accessibility.
*/

-- ============================================================
-- Stage 5: Construction & Supply Analysis
-- ============================================================

-- ============================================================
-- Q1. Which Years Recorded the Highest Number of New
-- Property Developments?
--
-- Objective:
-- Analyze housing supply growth over time.
-- ============================================================

SELECT Year,
       SUM(New_Construction_Count) AS New_Properties_Built
FROM market
GROUP BY Year
ORDER BY New_Properties_Built DESC;

-- ============================================================
-- BUSINESS INSIGHTS
-- ============================================================

/*
• The housing market experienced a significant construction
  boom during 2020.
• Construction activity declined throughout 2021 and 2022,
  reducing the pace of housing supply expansion.
• Lower housing supply may contribute to increased buyer
  competition and rising property prices.
• A modest recovery in 2023 suggests improving market
  confidence and renewed development activity.
*/

-- ============================================================
-- Q2. Which Cities Experienced the Highest Level of
-- New Construction Activity?
--
-- Objective:
-- Identify cities with the strongest housing development.
-- ============================================================

SELECT City,
       SUM(New_Construction_Count) AS New_Properties_Built
FROM market
GROUP BY City
ORDER BY New_Properties_Built DESC;

-- ============================================================
-- BUSINESS INSIGHTS
-- ============================================================

/*
• Los Angeles recorded the highest construction activity.
• Seattle and Chicago also maintained strong development
  pipelines, indicating continued housing expansion.
• New York recorded the lowest construction activity.
*/

-- ============================================================
-- Q3. How Does New Construction Influence Home Prices?
--
-- Objective:
-- Examine the relationship between housing supply and
-- average home prices.
-- ============================================================

SELECT Year,
       SUM(New_Construction_Count) AS New_Properties_Built,
       ROUND(AVG(Avg_Home_Price),2) AS Avg_Home_Price
FROM market
GROUP BY Year
ORDER BY Year;

-- ============================================================
-- BUSINESS INSIGHTS
-- ============================================================

/*
• Increased construction activity appears to support
  housing affordability by expanding supply.
• Periods of reduced construction often coincide with
  higher home prices due to supply shortages.
• The construction peak observed in 2020 aligned with
  relatively lower average home prices.
*/

-- ============================================================
-- Q4. How Do Interest Rates Impact Average Home Prices?
--
-- Objective:
-- Analyze pricing sensitivity to changing interest rates.
-- ============================================================

WITH ninjas AS (
SELECT Interest_Rate,
       ROUND(AVG(Avg_Home_Price),2) AS Average_Listing_Price
FROM market
GROUP BY Interest_Rate
)

SELECT Interest_Rate, Average_Listing_Price,
ROUND((Average_Listing_Price -LAG(Average_Listing_Price) OVER(ORDER BY Interest_Rate)) /
LAG(Average_Listing_Price) OVER(ORDER BY Interest_Rate)*100,2) AS Percent_Change
FROM ninjas;

-- ============================================================
-- BUSINESS INSIGHTS
-- ============================================================

/*
• The analysis suggests a generally inverse relationship
  between interest rates and housing prices.
• Rising interest rates reduce purchasing power and may
  slow housing demand.
*/

/*
===============================================================
FINAL PROJECT CONCLUSION
===============================================================

REAL ESTATE MARKET ANALYSIS – KEY FINDINGS

• San Francisco emerged as the strongest premium housing
  market, recording the highest average home prices,
  rental values, and housing demand levels.

• Miami maintained relatively high property valuations,
  reflecting continued strength in premium residential markets.

• Los Angeles and Chicago attracted the highest investor
  activity, indicating strong confidence in future growth
  and investment opportunities.

• Seattle demonstrated a balanced combination of housing
  demand, affordability, and market stability, making it
  an attractive market for long-term buyers and investors.

• Housing affordability challenges were observed across
  all income groups, highlighting increasing pressure on
  homebuyers and the importance of income-to-price ratios.

• Construction activity peaked in 2020 before moderating
  in subsequent years, reflecting changing development
  patterns and housing supply dynamics.

• Interest rates showed a noticeable relationship with
  home prices, suggesting that financing costs play an
  important role in shaping housing market trends.

• Housing demand, rental performance, investor activity,
  and construction levels collectively influence property
  valuations and long-term market attractiveness.

• Cities with strong demand, healthy rental markets,
  active investor participation, and sustainable housing
  development are likely to offer the most attractive
  long-term real estate investment opportunities.

===============================================================
PROJECT STATUS : COMPLETED
TOOLS USED     : MYSQL, POWER BI
ANALYSIS TYPE  : EXPLORATORY DATA ANALYSIS + BUSINESS INSIGHTS
DOMAIN         : REAL ESTATE ANALYTICS
===============================================================
*/