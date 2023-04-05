# The Channel development team requires all data available about the channels for their new dashboard team. 
#Run the following query to get the all channel information
select *
from CHANNEL;

#Channel Development team requires the following information for their weekly-channel presentation:
#list of all channel names,
#channel names ordered by commission in starting with the highest commission rate,
#channel names which have commission rates higher than 10%
select ChannelName
from CHANNEL;

select ChannelName, ChannelCommission
from CHANNEL
order by ChannelCommission DESC;

select ChannelName, ChannelCommission
from CHANNEL
where ChannelCommission>0.1;

# team requires the actual prices for the stays in the system. 
#Calculate the actual price using the price and discount amount from the corresponding tables. 
#Run the following query to get the actual price data
select StayID, StayPrice *(1-StayDiscount) AS 'Actual Price'
from STAY;

# team indicates that the retrieved data is not suitable for making payments as currency. 
#You need to round up the actual prices to have only 2 decimals
select StayID, ROUND(StayPrice*(1-StayDiscount),2) AS 'Actual Price Rounded'
from STAY;

#The InstantStay Owner Relationships team wants to send thank you notes to the owners
#joined in the last year and still in the InstantStay system. Collect all owners joined in the last year 
#and did not leave the system yet
select *
from OWNER
where (OwnerJoinDate>=DATE_ADD(CURDATE(),INTERVAL-1 YEAR)) and OwnerEndDate is NULL;

#The InstantStay Owner Relationships team wants to send reminders to the owners that left the system. 
#Collect the email address of the owners, notification date as one week later of their leave 
#and last day of the month for financial closure
select OwnerEmail, DATE_ADD(OwnerEndDate,INTERVAL 1 WEEK) AS NotificationDate,LAST_DAY(OwnerEndDate)AS FinancialClosure
from OWNER
where OwnerEndDate is NOT NULL;

