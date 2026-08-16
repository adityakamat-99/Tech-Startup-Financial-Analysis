create or replace view vw_Dim_Company as
select
	Company_ID,
    Domain,
    Founding_Year,
    AI_Adoption_Level,
    Acquisition_Status
from startups;

create or replace view vw_Dim_Location as
select
	Company_ID,
    Country,
    City
from startups;

create or replace view vw_Fact_Financials as
select
	Company_ID,
    Funding_Stage,
    Total_Funding_USD_Millions,
    Valuation_USD_Millions,
    Revenue_ARR_Millions,
    Monthly_Burn_Rate_Millions,
    Runway_Months_2024,
    Investor_Tier
from startups;

create or replace view vw_Fact_Headcount as
select
	Company_ID,
    Peak_Headcount_2023,
    Layoffs_2024_2025,
    Current_Headcount_2026
from startups;

