CREATE TABLE startups (
    Company_ID VARCHAR(50) PRIMARY KEY,
    Domain VARCHAR(100),
    Founding_Year INT,
    Country VARCHAR(100),
    City VARCHAR(100),
    Funding_Stage VARCHAR(50),
    Total_Funding_USD_Millions DECIMAL(10,2),
    Valuation_USD_Millions DECIMAL(10,2),
    Revenue_ARR_Millions DECIMAL(10,2),
    Monthly_Burn_Rate_Millions DECIMAL(10,2),
    Runway_Months_2024 DECIMAL(5,1),
    Peak_Headcount_2023 INT,
    Layoffs_2024_2025 INT,
    Current_Headcount_2026 INT,
    Investor_Tier VARCHAR(100),
    AI_Adoption_Level VARCHAR(50),
    Acquisition_Status VARCHAR(50)
);
TRUNCATE TABLE startups;
LOAD DATA LOCAL INFILE 'C:/Users/adity/OneDrive/Coding Ninjas/Startup Dashboard/global_tech_startups_2026.csv'
INTO TABLE startups
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' -- Use '\r\n' if you are on Windows and '\n' fails
IGNORE 1 ROWS; -- This skips the header row of your CSV

select*
from startups;