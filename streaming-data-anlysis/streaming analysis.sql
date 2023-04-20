USE postgres;
-- Question #1
-- Reminder: Only registered devices would have an user_id. 

select
	TO_CHAR(sessions_start, 'YYYY-MM') as month,
	round(COUNT(distinct s.device_id)::numeric / COUNT(u.device_id)::numeric, 2) as registered
from
	user as u
join session as s on
	s.device_id = u.device_id
group by
	month;


-- Question #2

-- CTE to calculate total view_time
with views as (
select 
	to_CHAR(sessions_start, 'YYYY-MM') as month,
	user_id,
	SUM(duration_seconds) as view_time
from
	user as u
join session as s on
	s.device_id = u.device_id
where
	signup_country != 'Canada'
group by 
	month,
	u.user_id),
	
-- CTE to rank top users, could've been done in views CTE but I like using a second one to more clarity to proccess
rnk as (
select 
	month,
	user_id,
	view_time,
	dense_rank() over(partition by month
		order by view_time desc) as ranking
from
	views
)

-- Query from the finalized ideal data set
select
	month,
	user_id,
	view_time,
	ranking
from
	rnk
where
	month = '2022-09'
	and ranking <= 5
order by
	view_time desc;


-- Question #3

-- This question is pretty similar to #2
-- Rather than repeat the two CTE form above, going to put it all into one CTE

with rnks as (
select
	to_CHAR(sessions_start, 'YYYY-MM') as month,
	u.user_id as user_id,
	sum(duration_seconds) as watch_time,
	dense_rank() over(partition by (to_CHAR(sessions_start, 'YYYY-MM'))
		order by (SUM(duration_seconds)) desc) as watch_rank
from
	user as u
join session as s on
	s.device_id = u.device_id
group by
	month,
	user_id)

select
	month,
	user_id,
	watch_rank
from
	rnks
where
	watch_rank <= 5
	and month >= '2022-01';


-- Question #4

-- Aggregation needs to be done across two CTE, one for user_id and one for device_id

-- CTE for total view_time by user
with watches as (
select
	u.user_id as users,
	sum(duration_seconds) as user_views
from
	user as u
join session as s on
	s.device_id = u.device_id
group by 
	u.user_id
),

--CTE for viewtime by device
devs as (
select 
	u.device_id as device,
	sum(duration_seconds) as dev_views,
	rank() over(partition by u.user_id
order by
	sum(duration_seconds) desc) as rnk
from
	user as u
join session as s on
	s.device_id = u.device_id
group by
	u.device_id
order by
	u.user_id,
	rnk
)

-- Combine and query using original user table as a connection
select 
	users,
	user_views,
	device as top_device
from
	watches as w
join user as u on
	u.user_id = w.users
join devs as d on
	d.device = u.device_id
where
	rnk = 1
order by
	users;


-- Question #5

with logins as (
select
	device_id,
	to_char(sessions_start, 'YYYY-MM-DD')::date as date_watched,
	sum(duration_seconds) / 60 as mins,
	row_number() over(partition by device_id
		order by sessions_start) as login_no,
	lead(to_char(sessions_start, 'YYYY-MM-DD')::date) over (partition by device_id
		order by sessions_start) as next_login
from
	session
group by
	device_id,
	sessions_start
having
	sum(duration_seconds) / 60 >= 30
order by
	device_id,
	sessions_start;

)
-- Devices with < 30 are already filtered out by CTE
select 
	distinct device_id
from
	logins
where 
	next_login - date_watched <= 30
	and login_no = 1;

-- You want to set login_no = 1 because it sets you in the first 30 days, otherwise you just end up with users who have less than 30 days between any login


