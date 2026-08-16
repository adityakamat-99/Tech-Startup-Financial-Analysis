/* ============================================================================
   QUERY 1: The "Danger Zone" Analysis (Runway Sustainability)
   Business Problem: 
   Identify which startup sectors have the highest percentage of companies at 
   critical risk of running out of cash (defined as having under 6 months of 
   financial runway).
   Skills Showcased: 
   Common Table Expressions (CTEs), CASE WHEN logic, Percentage Aggregations
============================================================================ */
with cte as(
select
	c.Domain,
    count(c.company_id) as Total_companies,
    sum(case when f.Runway_Months_2024 < 6 then 1 else 0 end) as High_Risk_Count
from vw_dim_company as c
inner join vw_fact_financials as f
on c.company_id = f.company_id
group by
	c.Domain
)
select
	Domain,
    Total_companies,
    High_Risk_Count,
    round((High_Risk_Count*100/Total_companies),2) as Risk_percentage
from cte
order by
	Risk_percentage desc;
    
/* ============================================================================
   QUERY 2: Regional Tech Hub Ranking (Capital Efficiency)
   Business Problem: 
   Evaluate and rank different cities within India based on their capital 
   efficiency, calculated by comparing total funding secured against total 
   annual recurring revenue (ARR) generated.
   Skills Showcased: 
   Window Functions (RANK() OVER), NULLIF to prevent divide-by-zero, JOINs
============================================================================ */
select
	l.City,
    sum(f.total_funding_USD_Millions) as Total_FUnding,
    sum(f.revenue_ARR_Millions) as Total_Revenue,
    round((sum(f.total_funding_USD_Millions)/ ifnull(SUM(f.Revenue_ARR_Millions), 0)),2) as Efficiency_Ratio,
    rank() over(order by (sum(f.total_funding_USD_Millions)/ ifnull(SUM(f.Revenue_ARR_Millions), 0)) asc) 
    as National_Efficiency_Rank
from vw_dim_location as l
inner join vw_fact_financials as f
on l.company_id = f.company_id
where l.country = "India"
group by
	l.City;
    
    
    
/* ============================================================================
   QUERY 3: Talent Retention vs. AI Adoption
   Business Problem: 
   Analyze whether startups with a "High" AI adoption level have been more 
   successful at retaining their workforce compared to those with lower adoption, 
   measuring the drop from peak 2023 headcount to current 2026 headcount.
   Skills Showcased: 
   Complex mathematical aggregations across joined Dimension and Fact tables, 
   handling NULL categorical data.
============================================================================ */
select
	c.AI_adoption_level,
    sum(h.peak_headcount_2023) as Total_peak_Headcount,
    sum(h.current_headcount_2026) as Total_current_Headcount,
    round((sum(h.current_headcount_2026)*100/ifnull(sum(h.peak_headcount_2023),0)),2) as Retention_Percent
from vw_dim_company as c
inner join vw_fact_headcount as h
on c.company_id = h.company_id
where c.AI_adoption_level is not null
group by c.AI_adoption_level
order by
	Retention_Percent desc;
    
    
    
/* ============================================================================
   QUERY 4: Identifying the Dominant Hub per Country
   Business Problem: 
   Isolate the absolute top-performing tech hub (city) in every country based 
   on total funding volume, strictly filtering for established ecosystems that 
   host more than 50 startups.
   Skills Showcased: 
   Advanced Window Functions (DENSE_RANK() OVER with PARTITION BY), Multiple 
   JOINs, filtering aggregated groupings.
============================================================================ */
with cte as(
	select
		l.Country,
        l.City,
        sum(f.Total_Funding_USD_Millions) as Total_City_Funding,
        count(c.Company_ID) as Startup_Count,
        dense_rank()over( partition by l.country order by sum(f.Total_Funding_USD_Millions) desc) as Hub_Rank
	from vw_dim_location as l
    inner join vw_fact_financials as f 
    on l.Company_ID = f.Company_ID
    inner join vw_dim_company as c
    on c.Company_ID = l.Company_ID
    group by 
		l.Country,
        l.City
)
select
	Country,
    city as Leading_Tech_Hub,
    Total_City_FUnding,
    Startup_Count
from cte
where
	Hub_Rank = 1
    and
    Startup_Count >= 50
order by 
	Total_City_FUnding desc;
    
    
/* ============================================================================
   QUERY 5: Sector-Level "Cash Burners" vs. Global Average
   Business Problem: 
   Pinpoint specific startup domains that are burning cash at a rate 
   significantly higher than the global industry average across all sectors.
   Skills Showcased: 
   Scalar Subqueries within a HAVING clause to dynamically filter aggregated 
   groups against a global metric.
============================================================================ */
select
	c.Domain,
    round(avg(f.Monthly_Burn_Rate_Millions),2) as Avg_Domain_Burn,
    count(c.Company_ID) as Total_Startups
from vw_dim_company as c
inner join vw_fact_financials as f
on c.Company_ID = f.Company_ID
group by
	c.Domain
having avg(f.Monthly_Burn_Rate_Millions) >
	(select avg(Monthly_Burn_Rate_Millions) from vw_fact_financials)
order by
	Avg_Domain_Burn desc;
    
    
/* ============================================================================
   QUERY 6: Funding Stage Cross-Tabulation (Pivot Table)
   Business Problem: 
   Provide a clean, single-view breakdown showing the distribution of startups 
   across "Early Stage" (Seed/Series A), "Growth Stage" (Series B/Series C+), 
   and "Pre-IPO" stages across different domains.
   Skills Showcased: 
   Creating a manual pivot table entirely within SQL using conditional 
   aggregations (SUM combined with CASE WHEN IN).
============================================================================ */
select
	c.Domain,
    sum(case when f.funding_stage in ("Seed", "Series A") then 1 else 0 end) as Early_Stage,
    sum(case when f.funding_stage in ("Series B", "Series C+") then 1 else 0 end) as Growth_stage,
    sum(case when f.funding_stage = "Pre-IPO" then 1 else 0 end) as Pre_IPO_Count
from vw_dim_company as c
inner join vw_fact_financials as f
on c.company_id = f.company_id
group by
	c.Domain
order by
	Pre_IPO_Count desc;
    

/* ============================================================================
   QUERY 7: Identifying Resilient Late-Stage Survivors
   Business Problem: 
   Determine which domains possess the highest volume of highly resilient 
   startups—defined as companies that suffered severe layoffs (over 30% of 
   their peak workforce) but still secured or maintained late-stage funding 
   (Series C+ or Pre-IPO).
   Skills Showcased: 
   Complex multi-table JOIN operations, advanced percentage math across 
   different tables, and multiple precise filtering conditions.
============================================================================ */
select
	c.Domain,
    count(c.Company_ID) as Resilient_Startups,
    round(avg(h.layoffs_2024_2025 * 100 / ifnull(h.Peak_headcount_2023,0)),2) as Avg_layoff_Percent
from vw_dim_company as c
inner join vw_fact_headcount as h
	on c.Company_ID = h.Company_ID
inner join vw_fact_financials as f
	on f.Company_ID = c.Company_ID
where
	f.funding_stage in ("Series C+", "Pre-IPO")
    and
    (h.layoffs_2024_2025 * 100 / ifnull(h.Peak_headcount_2023,0)) > 0.30
group by
	c.Domain
order by
	Resilient_Startups desc;
