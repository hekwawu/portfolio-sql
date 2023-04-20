### Background
This analysis looks at user info and streaming data for an online streaming platform. 

Project folder contains two files:
- Data set creation - random data set using [Mockaroo](https://www.mockaroo.com/), in accordance with column definitions
- Queries to answer questions

### Table Details
#### User: details of the registered user 

Columns:
- user_id
- device_id
- sigup_country
> If the user is not registered, we would only have the device_id but no user_id. 

#### Sessions: users sessions generated when they are watching the content 
> Devices do not need a user_id in order to watch content

Columns:
- device_id
- sessions_start: the timestamp of device starting the video 
- duration_seconds: the total duration watching per session in seconds 


### Questions

Q1: Only registered devices would have an user_id. Write a query that returns the % of viewing devices that have already registered per month .

Q2: Query top 5 user_ids by total duration in September 2022. Exclude user_ids with signup_country 'Canada'	

Q3: Query top 5 users by total duration for each month in 2022

Q4: Write a query to find every user’s most used device & their total duration viewed (across all devices)

Q5: Write a query to return the devices that viewed at least 2 days with >= 30 minutes per day in the first 30 days

