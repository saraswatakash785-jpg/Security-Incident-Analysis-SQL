-- Security Incident Analysis (MySQL)
-- Tables: organizations, security_incidents, incident_systems, systems, users, network_events
-- Import the CSV files as tables with the same names, then select your database with USE before running these queries.

-- Q.1-Show the organization ID, industry, country and total number of security incidents recorded for each
-- organization. Also display the number of incidents classified as 'Critical' or 'High'. Show only
-- organizations having more than 3 security incidents.Order the results by total incidents in descending order.
select
organizations.org_id, organizations.industry, organizations.country,
    COUNT(security_incidents.incident_id) as Total_security_incidents,
    count(Case when security_incidents.severity IN ('Critical', 'High')
    then security_incidents.incident_id End ) as incident_classification
FROM organizations
JOIN security_incidents on security_incidents.org_id = organizations.org_id
group by organizations.org_id , organizations.industry , organizations.country
having COUNT(security_incidents.incident_id) > 3
ORDER BY Total_security_incidents desc;

-- Q.2-Show the date and total number of network events recorded on each day. Also display:1. The previous
-- day's network event count. 2. The 7-day moving average of network events. 3. The difference between the
-- current day's events and previous day's events.Display only dates where network activity is higher than
-- the 7-day moving average.Arrange the results chronologically.
With daily_events as(
    SELECT network_events.timestamp, COUNT(*) AS total_number_of_events FROM network_events
group by network_events.timestamp),
moving_analysis AS
(SELECT timestamp, total_number_of_events,LAG(total_number_of_events)
OVER(ORDER BY timestamp) AS previous_day_events,
   AVG(total_number_of_events) OVER(ORDER BY timestamp Rows between 6 preceding and current row)
   AS moving_average_7_days FROM daily_events)
select timestamp, total_number_of_events,
previous_day_events,
moving_average_7_days,
total_number_of_events - previous_day_events
    AS difference_in_events
From moving_analysis
Where total_number_of_events > moving_average_7_days
ORDER BY timestamp;

-- Q.3-Show the month and total number of security incidents recorded during each month. Also display:1. The
-- previous month's incident count.2. The next month's incident count.3. The difference between the current
--  and previous month's incidents.4. The percentage increase or decrease compared with the previous month.
-- Categorize monthly performance as Increasing, Decreasing or No Change. Arrange the results chronologically.
With a as(
select date_format(security_incidents.discovered_date, '%Y-%m') as Month, count(*) as total_security_incidents
from security_incidents group by Month),
Monthly_security as (select Month, total_security_incidents, LAG(total_security_incidents)
OVER(ORDER BY Month) as
 Previous_month_incident_count, LEAD(total_security_incidents)
OVER(ORDER BY Month) as Next_month_incident_count,
 total_security_incidents -
LAG(total_security_incidents) OVER(ORDER BY Month)
as difference_of_incidents from a)
 select Month, total_security_incidents , Previous_month_incident_count, Next_month_incident_count,
 difference_of_incidents, (
    total_security_incidents - previous_month_incident_count
) / Previous_month_incident_count * 100
AS percentage_change, CASE
 when Previous_month_incident_count IS NULL THEN 'First Month'
    when difference_of_incidents > 0 then 'Increasing'
    WHEN difference_of_incidents < 0 THEN 'Decreasing'
    else 'No Change'
END as monthly_performance
 from Monthly_security Order by Month ASC;

-- Q.4-Show the operating system, month and total number of incidents associated with each operating system.Also
-- display:1. The cumulative number of incidents for each operating system over time.2. The percentage
-- contribution of each operating system to the overall incident count.3. The rank of each operating system
-- based on its total number of incidents.Arrange the results by operating system and month.
with op_incidents as (select systems.os_type as operating_systems, date_format(security_incidents.discovered_date,
 '%Y-%m') as month, count(distinct security_incidents.incident_id) as total_incidents
from security_incidents
join incident_systems on incident_systems.incident_id = security_incidents.incident_id
join systems on systems.system_id = incident_systems.system_id
group by operating_systems, month),
incidents as (
select operating_systems, month, total_incidents, SUM(total_incidents) over(partition by operating_systems
 order by month) as cumulative_no_of_incidents, SUM(total_incidents) OVER (PARTITION BY operating_systems)
 AS os_total_incidents,
SUM(total_incidents) OVER () AS overall_incidents
from op_incidents),
final_analysis as
(select operating_systems, month,
total_incidents, cumulative_no_of_incidents, ROUND(os_total_incidents * 100.0 / overall_incidents, 2)
AS percentage_contribution_of_os,
dense_rank() OVER (ORDER BY os_total_incidents DESC) AS Rank_no FROM incidents)
select * from final_analysis order by operating_systems, month;

-- Q.5-Organization Incident Benchmark Analysis 1. Show organization ID, industry and country. 2. Calculate
-- total security incidents for each organization. 3. Identify organizations whose incident count is
-- greater than the average incident count across organizations having at least one incident.
-- 4. Arrange results by total incidents in descending order.
select organizations.org_id, organizations.industry, organizations.country ,
count(distinct security_incidents.incident_id) as total_security_incidents
from organizations
join security_incidents on security_incidents.org_id = organizations.org_id
group by organizations.industry, organizations.country, organizations.org_id
HAVING COUNT(DISTINCT security_incidents.incident_id) > (SELECT AVG(organization_incident_count) from
(select COUNT(distinct incident_id) as organization_incident_count
From security_incidents GROUP BY org_id) as average_incidents)
ORDER BY total_security_incidents desc;

-- Q.6-Organizations Without Security Incidents 1. Identify organizations that have never recorded any security
-- incident. 2. Display organization ID, industry and country.3. Show only organizations with zero security
-- incidents.4. Arrange results by organization ID.
select organizations.org_id, organizations.industry,organizations.country from organizations
left join security_incidents on organizations.org_id = security_incidents.org_id
where security_incidents.org_id IS NULL
order by organizations.org_id;
