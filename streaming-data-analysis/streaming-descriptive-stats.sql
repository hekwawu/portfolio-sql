-- Note: All device_ids are subscribers. Next steps will be to update code to have non-subscribers and conduct further analysis

-- BASIC SUMMARY STATISTICS - Session Duration
select 
	avg(duration_seconds) as avg_duration,
	percentile_disc(0.50) within group (order by duration_seconds)as median_duration,
	stddev_samp(duration_seconds) as stdev_duration,
	percentile_disc(0.25) within group (order by duration_seconds) as q1_duration,
	percentile_disc(0.75) within group (order by duration_seconds)as q3_duration,
	(percentile_disc(0.75) within group (order by duration_seconds)) - (percentile_disc(0.25) within group (order by duration_seconds)) as IQR_duration,
	min(duration_seconds) as min_duration,
	max(duration_seconds) as max_duration,
	max(duration_seconds) - min(duration_seconds) as range_duration
from session;
-- Median and average are relatively close, however; range is 2x the IQR, suggesting we may have serious outliers. Going to set up bins to further look at this distribution

-- Bin generation - will likely play with lower and upper to get the best buckets
with bins as (
	select
		generate_series(0,18000,2000) as lower,
		generate_series(2000,20000,2000) as upper
)

select
	lower,
	upper,
	count(duration_seconds) as value_count,
	(count(duration_seconds)/(
		select 
			count(duration_seconds)::numeric
		from session))*100 as percent_of_total
from bins 
left join session on duration_seconds >= lower
	and duration_seconds < upper
group by lower,upper
order by lower;
--- Considering middle of data is ~ 10K, nearly 11% of sessions have >18,000 seconds_duration

-- Going to go for a different approach; seeing what the percentiles are across the board
ntile
	

-- TRENDED SESSION DURATION
select 
	date_part('month',sessions_start::date) as month,
	round(avg(duration_seconds)::numeric,2) as avg_duration
from session
	group by ROLLUP(month)
	order by month;
-- lowest month: November
-- highest month: September

-- POWER USERS: COUNTRY
-- Session duration by country
select 
	signup_country as country,
	COUNT(distinct s.device_id) as device_count,
	round(avg(duration_seconds)::numeric,2) as avg_duration
from session as s
	JOIN users as u ON u.device_id = s.device_id 
	group by (country)
	order by avg_duration desc;

-- There appear to be a lot of countries with only one user, we may want to exclude these moving forward





--------------------------

-- TO DO: edit data creation so not everything is a subscriber
-- Create a temp table with subscriber vs non-subscriber status to make it easier
--create view subscriber_table as
--select
--	distinct device_id,
--	exists (
--		select 
--		device_id 
--		from users
--		where device_id = session.device_id) as subscriber_status
--from session;
--
--select *
--from subscriber_table;
--
---- Compare subscriber vs non-subscriber average
--select 
--	subscriber_status,
--	round(avg(duration_seconds)::numeric,2) as avg_duration
--from session as s
--	right join subscriber_table as t on t.device_id = s.device_id
--group by subscriber_status;


