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


#The InstantStay Legal team requires all house owners first and 
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



#The InstantStay House Development team wants to track the extra facilities and/or benefits such as amenities or insurances, 
#provided with the houses. The team needs you to create a new database table called EXTRA with fields ExtraID and ExtraDescription
create table EXTRA(
  ExtraID INT PRIMARY KEY NOT NULL,
  ExtraDescription VARCHAR(20) NOT NULL
);

DESCRIBE EXTRA;



#The House Development team wants to combine extras and house information in a separate table. 
#Create a new table called HOUSE_EXTRA with the fields ExtraID and HouseID. Use foreign keys to add the respective references to their own tables.

#In addition, when the IDs of the houses or extras are updated or changed, the changes should be automatically reflected in the HOUSE_EXTRA table 
#with the ON UPDATE CASCADE references. Similarly, when the houses or extras are deleted, the corresponding rows from the HOUSE_EXTRA table 
#will also need to be deleted using the ON DELETE CASCADE statements
CREATE TABLE HOUSE_EXTRA(
  HouseID INT NOT NULL,
  ExtraID INT NOT NULL,
  PRIMARY KEY(HouseID, ExtraID),
  FOREIGN KEY(HouseID)
      REFERENCES HOUSE(HouseID)
      ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY(ExtraID)
      REFERENCES EXTRA(ExtraID)
      ON DELETE CASCADE ON UPDATE CASCADE
);

#The Owner Relationships team wants to track the active owners in the InstantStay system. 
#The team requested a new table, called ACTIVE_OWNER, which should have all the related information of the active owners currently
CREATE TABLE ACTIVE_OWNER(
  OwnerID INT NOT NULL,
  OwnerFirstName VARCHAR(50) NOT NULL,
  OwnerLastName VARCHAR(50)NOT NULL,
  OwnerStatus BOOL DEFAULT TRUE,
  OwnerEmail VARCHAR(50) NOT NULL
)AS SELECT OwnerID, OwnerFirstName, OwnerLastName,
 OwnerEmail FROM OWNER 
 WHERE OwnerEndDate IS NULL;


SELECT * FROM ACTIVE_OWNER;



#The owner relationship team wants to reduce the time required to access all the active owner details. 
#The team has highlighted the fact that it needs extra effort and time to fetch the customer information 
#when they are only provided with the first name. The team is looking for a solution to minimize the time required to fetch the required data.

#In such case, you need to create an INDEX for first name and last name of the active owners.
#Indexes make it easier to find rows in MySQL. Without an index, the MySQL engine will look for all the rows to find the searched items.
#Indexes are created over the tables and their fields
CREATE INDEX NameSearch ON ACTIVE_OWNER(
  OwnerFirstName, OwnerLastName
);


SHOW INDEX FROM ACTIVE_OWNER;

#The Owner Relationship team wants to ensure that there are no multiple active owners with the same first name, last name and email.
#To ensure this, you need to create a CONSTRAINT on the ACTIVE_OWNER table to ensure the teams requirement
ALTER TABLE ACTIVE_OWNER
ADD CONSTRAINT DuplicateCheck UNIQUE (
  OwnerFirstName, OwnerLastName, OwnerEmail
);


#The House Development team considered that the extras for the houses should not be free. 
#Therefore, they want to extend their EXTRA table to cover pricing information. Change the corresponding table with the following command
ALTER TABLE EXTRA
ADD COLUMN ExtraPrice FLOAT;

DESCRIBE EXTRA;


#The House Development team wants to ensure that the default price of the extras should be 0 instead of NULL. 
#Their calculation systems resulted with errors when NULL values are returned. 
$You need to set default value for the ExtraPrice column of the EXTRA table
ALTER TABLE EXTRA
ALTER COLUMN ExtraPrice SET DEFAULT 0;


#The Owner Relationship team requested a constraint on the first names and last names of the active users. 
#The team does not want dummy owner names with only 1 letter in the system, therefore, you need to insert the following CHECK to the ACTIVE_OWNER table
ALTER TABLE ACTIVE_OWNER ADD CHECK (LENGTH(OwnerFirstName) > 2 AND LENGTH(OwnerLastName) > 2);

#The House Development team collected the extras and they want you to update the system’s database with the relative information:

#ID: 1, Description: Liability Insurance, Price: 0
#ID: 2, Description: Personal Insurance, Price: 100
#ID: 3, Description: Household Insurance, Price: 125
INSERT INTO EXTRA(ExtraID,ExtraDescription) VALUES (1, 'Liability Insurance');
INSERT INTO EXTRA VALUES (2, 'Personal Insurance', 100);
INSERT INTO EXTRA VALUES (3, 'Household Insurance', 125);

#The House Development team mentioned that all the houses in the state NY already have Liability Insurance (ID: 1). 
#Add all the houses in NY with the ExtraID value of 1 into the HOUSE_EXTRA table
INSERT INTO HOUSE_EXTRA(HouseID, ExtraID) 
SELECT HouseID, '1' FROM HOUSE WHERE HouseState = 'NY'; 

SELECT * FROM HOUSE_EXTRA;

#The Owner Relationship team realized that they do not need an OwnerStatus column in the ACTIVE_OWNER table.
#The team want you to remove the column the from the table
ALTER TABLE ACTIVE_OWNER DROP COLUMN OwnerStatus;

#The House Development team wants to update the price of the liability insurance extra to 75 and wants to remove the household insurance option.
#However, the team does not store the ExtraID and wants to work with the ExtraDescription. 
#Prepare the update script by temporarily inactivating the safe update feature of MySQL
SET SQL_SAFE_UPDATES = 0; -- temporarily inactivating the safe update feature of MySQL
 
UPDATE EXTRA 
SET 
    ExtraPrice = 75
WHERE
    ExtraDescription = 'Liability Insurance';
DELETE FROM EXTRA 
WHERE
    ExtraDescription = 'Household Insurance'; 
SET SQL_SAFE_UPDATES = 1; -- activating the safe update feature of MYSQL


SELECT * FROM EXTRA;


#The House Development team wants a SQL script to add multiple rows to the HOUSE_EXTRA table in a batch. 
#You need to create a transaction, add the rows and finally commit the changes
SET autocommit=OFF;
START TRANSACTION;
INSERT INTO HOUSE_EXTRA VALUES('2','1');
INSERT INTO HOUSE_EXTRA VALUES('2','2');
COMMIT;
SET autocommit=ON;


SELECT * FROM HOUSE_EXTRA;



#The House Development team wants a SQL script to add ExtraID 1 and 2 with HouseID 3 to the HOUSE_EXTRA table. 
#However, they do not want this data in the database after they complete their operations. You need to create a transaction 
#with the rollback of the changes
SET autocommit=OFF;
START TRANSACTION;
INSERT INTO HOUSE_EXTRA VALUES('3','1');
INSERT INTO HOUSE_EXTRA VALUES('3','2');
ROLLBACK;
SET autocommit=ON;

SELECT * FROM HOUSE_EXTRA;



#The Owner Relationship team realized that maintaining owners in two different tables is difficult.
#Therefore, they indicated that they do not need the ACTIVE_OWNER table anymore. You need to delete the table from the database
DROP TABLE ACTIVE_OWNER;


#The Owner Relationship team requested to work with a VIEW for active owners. 
#Create a VIEW with the name ACTIVE_OWNER from the table OWNER for the owners with end date is NULL
CREATE VIEW ACTIVE_OWNER AS
    SELECT 
       OwnerID, OwnerFirstName,OwnerLastName,OwnerEmail
    FROM
       OWNER 
    WHERE
       OwnerEndDate IS NULL;
      
      
SHOW FULL TABLES WHERE table_type = 'VIEW';



#The Owner Relationship team wants to update the email of the active owner whose ID is 5 with the address a.webber@xmail.au.
#Create an UPDATE statement to work over the ACTIVE_OWNER view
UPDATE ACTIVE_OWNER
SET 
    OwnerEmail='a.webber@xmail.au'
WHERE 
    OwnerID=5;


SELECT * FROM OWNER WHERE OwnerID = 5;


#The Owner Relationship team wants to add a new owner (Ece, Yilmaz, e.yilmaz@xmail.com, 2022-07-28). 
#However, they indicated that OwnerID fields should be automatically increased with the new additions to the system. 
#You need to make related adjustment to the OWNER table for the OwnerID field
ALTER TABLE OWNER CHANGE OwnerID OwnerID INT AUTO_INCREMENT;
INSERT INTO OWNER(OwnerFirstName,OwnerLastName,OwnerEmail,
OwnerJoinDate) VALUES('Ece','Yilmaz','e.yilmaz@xmail.com','2022-07-28');
SELECT *
FROM OWNER;


SELECT * FROM OWNER;


#The InstantStay Finance team requested a procedure to calculate the value-added tax (VAT) amount of the stays reservations in InstantStay.
#The team also indicated that VAT percentage is currently 18% but can be changed in the future. 
#You need to create a VATCalculator procedure with the VAT Percentage variable.
#We will create the procedure with a single SELECT statement where the price and VAT is calculated
DELIMITER $$
CREATE PROCEDURE VATCalculator()
BEGIN
DECLARE VAT_PERCENTAGE FLOAT DEFAULT 0.18;
SELECT StayPrice, ROUND(StayPrice * VAT_PERCENTAGE,2) AS VAT 
FROM STAY;
END$$
DELIMITER;


CALL VATCalculator();

#The InstantStay Marketing team wants to create guest levels such as GOLD, BRONZE and NEW. 
#The team will use these levels to provide additional campaigns and discounts. The team requested to create a function to set guest level as GOLD 
#when the user stays more than 2, BRONZE more than 1 and NEW otherwise. Create the following MySQL function to return the guest levels
DELIMITER $$
CREATE FUNCTION GuestStatus(
    id INT
)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE guestLevel VARCHAR(20);
    DECLARE stayCount INT;
    SET stayCount=(SELECT COUNT(StayID) 
    FROM STAY
    WHERE GuestID=id GROUP BY GuestID );
    
    IF(stayCount>2) THEN
       SET guestLevel='GOLD';
    ELSEIF(stayCount>1)THEN
       SET guestLevel='BRONZE';
    ELSE
       SET guestLevel='NEW';
    END IF;
    RETURN(guestLevel);
END$$
DELIMITER;

SELECT 
    GuestID,GuestStatus(GuestID)
FROM GUEST;


SELECT 
    GuestID, GuestStatus(GuestID)
FROM
    GUEST;
    

#The InstantStay Developers team requested a SQL statement to collect the emails from the tables in the InstantStay database. 
#Create a generic statement with the following script and execute it for testing
SET @table_name:='OWNER';
SET @OwnerEmailCollector:=CONCAT('SELECT OwnerEmail FROM ',@table_name);
PREPARE Statement FROM @OwnerEmailCollector;
EXECUTE Statement;


#The Developers team wanted to ensure that all the emails of the owners are lowercase in the database. 
#You need to create a trigger for before any INSERT statement on OWNER table
CREATE
     TRIGGER email_insert
  BEFORE INSERT ON OWNER FOR EACH ROW
     SET NEW . OwnerEmail=LOWER(NEW.OwnerEmail);

SHOW TRIGGERS;


#The Developers also indicated that emails should be lowercase even after they are updated in the database. 
#You need to create another trigger for before any UPDATE statements are called on the OWNER table
CREATE
    TRIGGER email_update
  BEFORE UPDATE ON OWNER FOR EACH ROW
    SET NEW . OwnerEmail=LOWER(NEW.OwnerEmail);

UPDATE OWNER
SET
    OwnerEmail='ECE.YILMAZ@XMAIL.COM'
WHERE OwnerID=8;

SELECT 
    OwnerEmail
FROM
    OWNER
WHERE 
    OwnerID=8;


#The Marketing team requested to create an email list with combining all the email addresses with ;. 
#You need to create a procedure that uses a CURSOR to iterate all over the emails in the OWNER table
DELIMITER $$ 
CREATE PROCEDURE OwnerEmailList(
    INOUT emailAddresses varchar(10000)
)
BEGIN
    DECLARE finished INTEGER DEFAULT 0;
    DECLARE emailAddress varchar(100) DEFAULT "";
 
    DECLARE cursorEmail CURSOR FOR SELECT OwnerEmail FROM OWNER;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished=1;
 
    OPEN cursorEmail;
    collect: LOOP
        FETCH cursorEmail INTO emailAddress;
        IF finished=1 THEN 
            LEAVE collect;
        END IF;
        SET emailAddresses=CONCAT(emailAddresses,";",emailAddress);
    END LOOP collect;
    CLOSE cursorEmail;
 
END$$
DELIMITER ;

SET @ownerEmailList="";
CALL OwnerEmailList(@ownerEmailList);
SELECT @ownerEmailList;




