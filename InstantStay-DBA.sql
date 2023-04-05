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

#The local authorities require all the guest information, 
#such as their first and last name and their stay start and end dates, 
#without checking the existence of reservation data
select GuestFirstName,GuestLastName,S.StayStartDate,S.StayEndDate
from GUEST G left join STAY S on S.GuestID=G.GuestID;


#The InstantStay Legal team requires all house owner's first and 
#last names along with their house ids and addresses. 
#Collect the information from HOUSE and OWNER tables and return in a consolidated way
select OwnerFirstName, OwnerLastName, HouseID, HouseAddress, HouseCity,HouseZIPCode,HouseState
from HOUSE join OWNER using (OwnerID);

#The InstantStay Finance team wants to collect all Stay IDs with the price, 
#discount and channel commission rate
select StayID,StayPrice,StayDiscount,ChannelCommission
from STAY s join CHANNEL c on s.ChannelID=c.ChannelID;

#In a case wherein guests are canceling the reservations or altering their stay days, the respective reimbursements and 
#cancellations payments are reflected with negative prices in the reservation tables. 
#The InstantStay Finance team requires the list of Stay IDs, GuestIDs, and the positive dollar amount rounded up to the nearest whole number
select StayID,GuestID,CEIL(ABS(StayPrice))as StayPrice
from STAY
where StayPrice<0;


#During the guest user analysis, developers realized 
#there could be duplicate users in the system. Check for the guests with the same name 
#but different GuestIDs to check whether they are duplicate or not
select * 
from GUEST g join GUEST h on g.GuestFirstName=h.GuestFirstName
                          and g.GuestLastName=h.GuestLastName
                          and g.GuestID!=h.guestID;
                          

#The InstantStay Finance team require all the available information about the reservations where the commission rate of the channel is higher than 10%
select *
from STAY
where ChannelID in (select ChannelID
                    from CHANNEL
                    where ChannelCommission>0.1);
                    

#The InstantStay Finance team requires average price per stay rounded to two decimal places for all the houses in the system.
#However, ensure that you do not include the cancelled stays with negative payment information
select HouseID, ROUND(AVG(StayPrice * (1-StayDiscount)),2) AS Payment
from STAY
where StayPrice>0
group by HouseID;

#The InstantStay Marketing team wants to learn the apartment that have more than average number of stays. Use the following script
select HouseID, count(StayID) AS Stays
from STAY
group by HouseID
having count(StayID)>(select avg(s.Stays)
                      from (select count(StayID) AS Stays
                      from STAY
                      group by HouseID) AS s);


#The Marketing team wants to get all the houses in the system which are larger than the average in size.
#For the calculation, you will compare against the AVG of HouseSquareMeter for all the houses in InstantStay.
select *
from HOUSE
where HouseSquareMeter>=(select avg(HouseSquareMeter)
                         from HOUSE);


#The Marketing team wants to get the name and email information for all the guests which have been registered 
#into the system so far though not stayed in any property yet. 
#The team is planning to use the collected information to fill the email templates with first name, 
#last name and email fields and then send the reminder emails
select g.GuestFirstName, g.GuestLastName, g.GuestEmail
from GUEST g
where g.GuestID != ALL(select distinct s.GuestID
                       FROM STAY s);
                       
#The InstantStay Legal team wants to send new General Data Protection Regulation (GDPR) emails 
#who are registered in the system. Collect email information for all owners and guests
select OwnerEmail
from OWNER
union select 
GuestEmail 
from GUEST;


#The InstantStay House Development team works on the houses and the coverage of InstantStay over the world. 
#They require a detailed analysis on the count of houses in the InstantStay. 
#To start with, they require the count of houses based in each state in a descending order
select HouseState, count(HouseID)
from HOUSE 
group by HouseState 
order by count(HouseID) desc;

#In addition, House Development team wants the same information (as mentioned in the Task 1) along with the city, state level details
select HouseState, HouseCity, count(HouseID)
from HOUSE 
group by HouseState, HouseCity 
order by count(HouseID) desc;


#The House Development team considers that having a limited availability of houses in a state could be risky and less beneficial for the business. 
#For Example, The InstantStay will be unable to process the reservation requests if the request count is higher than 
#count of registered houses in the state currently available to rent out. Therefore to take further steps to work on such issues, 
#the team requires to know all the states having less than 2 properties registered in the system
select count(HouseID), HouseState 
from HOUSE 
group by HouseState 
having count(HouseID)<2 
order by count(HouseID) desc;

#The House Development team also requires to calculate the total number of rooms available in each state
select HouseState, sum(HouseNumberOfRooms) AS TotalAvailability 
from HOUSE 
group by HouseState;


#In addition, the House Development team wants to know the largest and average house in terms of number of rooms for each state
select HouseState, max(HouseNumberOfRooms) AS LargestHouse, avg(HouseNumberOfRooms) AS AverageHouse
from HOUSE
group by HouseState;

#The InstantStay Marketing team is planning to create some maps to show the coverage of InstantStay throughout the country. 
#Therefore, they need some specific information such as distinct ZIP codes of all houses and distinct list of cities in two separate tables
select distinct HouseZIPCode
from HOUSE;

select distinct HouseCity 
from HOUSE;

#In addition,the InstantStay Marketing team wants to create a word cloud from the cities of the houses. 
#They want to learn the number of characters in the longest city
select max(length(HouseCity))
from HOUSE;


#The InstantStay Owner Relationships team focus on the success of InstantStay by creating strong connection to the owners. 
#They want to send celebration mails to the owners on their joining date in the system.
#They need the combined details which includes name and surname of the owners with their email addresses. 
#In addition, they are planning to make this as practice for every year. 
#The team requires the day and month of owners joining date to send emails on exact dates every year
select CONCAT(OwnerFirstName, CONCAT(' ', OwnerLastName)) AS Name, OwnerEmail, month(OwnerJoinDate) AS Month, DAY(OwnerJoinDate) AS Day 
from OWNER;

#The team wants to create a specialized carpets to the houses with the initials of owners. 
#They wanted to get the uppercase first letter of firstname and surname of the owners
select upper(SUBSTR(OwnerFirstName, 1, 1)) AS initial_1, upper(SUBSTR(OwnerLastName, 1, 1)) AS initial_2
from OWNER;

