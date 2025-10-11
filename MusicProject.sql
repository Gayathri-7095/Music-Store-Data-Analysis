Drop database music;
create database if not exists music ;
use music;
-- 1. Genre and MediaType
CREATE TABLE Genre (
	genre_id INT PRIMARY KEY auto_increment,
	name VARCHAR(120)
);

CREATE TABLE MediaType (
	media_type_id INT PRIMARY KEY auto_increment,
	name VARCHAR(120)
);
select * from employee;
-- 2. Employee
CREATE TABLE Employee (
	employee_id INT PRIMARY KEY auto_increment,
	last_name VARCHAR(120),
	first_name VARCHAR(120),
	title VARCHAR(120),
	reports_to INT,
	levels VARCHAR(255),
	birthdate DATE,
	hire_date DATE,
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100)
);

-- 3. Customer
CREATE TABLE Customer (
	customer_id INT PRIMARY KEY auto_increment,
	first_name VARCHAR(120),
	last_name VARCHAR(120),
	company VARCHAR(120),
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100),
	support_rep_id INT,
	FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id)
    on update cascade on delete cascade
);

-- 4. Artist
CREATE TABLE Artist (
	artist_id INT PRIMARY KEY auto_increment,
	name VARCHAR(120)
);

-- 5. Album
CREATE TABLE Album (
	album_id INT PRIMARY KEY auto_increment,
	title VARCHAR(160),
	artist_id INT,
	FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
    on update cascade on delete cascade
);

-- 6. Track
CREATE TABLE Track (
	track_id INT PRIMARY KEY auto_increment,
	name VARCHAR(200),
	album_id INT,
	media_type_id INT,
	genre_id INT,
	composer VARCHAR(220),
	milliseconds INT,
	bytes INT,
	unit_price DECIMAL(10,2),
	FOREIGN KEY (album_id) REFERENCES Album(album_id)
    on update cascade on delete cascade,
	FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id)
    on update cascade on delete cascade,
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
    on update cascade on delete cascade
);

-- 7. Invoice
CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY auto_increment,
	customer_id INT,
	invoice_date DATE,
	billing_address VARCHAR(255),
	billing_city VARCHAR(100),
	billing_state VARCHAR(100),
	billing_country VARCHAR(100),
	billing_postal_code VARCHAR(20),
	total DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
    on update cascade on delete cascade
);

-- 8. InvoiceLine
CREATE TABLE InvoiceLine (
	invoice_line_id INT PRIMARY KEY auto_increment,
	invoice_id INT,
	track_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id)
    on update cascade on delete cascade,
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
    on update cascade on delete cascade
);

-- 9. Playlist
CREATE TABLE Playlist (
 	playlist_id INT PRIMARY KEY auto_increment,
	name VARCHAR(255)
);

-- 10. PlaylistTrack
CREATE TABLE PlaylistTrack (
	playlist_id INT,
	track_id INT auto_increment,
	PRIMARY KEY (playlist_id, track_id),
	FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id)
    on update cascade on delete cascade,
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
    on update cascade on delete cascade
);

show tables;

select * from genre;
select * from mediatype;
select * from Employee;
insert into Employee(employee_id,last_name,first_name,title,levels,birthdate,hire_date,address,city,state,country,postal_code,phone,fax,email) 
values(9,'Madan','Mohan','Senior General Manager','L7','1961-01-26','2016-01-14','1008 Vrinda Ave MT','Edmonton','AB','Canada','T5K 2N1','+1 (780) 428-9482','+1 (780) 428-3457','madan.mohan@chinookcorp.com'); 
select * from Customer;
select * from Artist;
select * from Album;

/*Ensure secure_file_priv is properly configured
Before importing, run this command to check where MySQL allows file imports from:
*/
SHOW VARIABLES LIKE 'secure_file_priv';

-- Use the following SQL command to import track.csv:

-- LOAD DATA INFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\track.csv'
-- INTO TABLE music.track
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;



LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\track.csv'
INTO TABLE music.track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


select * from track;
select * from invoice;
select * from invoiceline;
select * from playlist;
select * from playlisttrack;



-- 1. Who is the senior most employee based on job title? 
SELECT 
    *
FROM
    employee
order by levels desc 
limit 1;
    
    
-- 2. Which countries have the most Invoices?
SELECT 
    billing_country, COUNT(invoice_id) AS numberofinvoices
FROM
    invoice
GROUP BY billing_country
ORDER BY numberofinvoices DESC
LIMIT 5;


-- 3. What are the top 3 values of total invoice?
SELECT 
    total
FROM
    invoice
ORDER BY total DESC
LIMIT 3;

-- 4. Which city has the best customers? - We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals
select billing_city,
sum(total) as invoicetotal
from invoice
group by billing_city
order by 
invoicetotal desc
limit 1;

-- 5. Who is the best customer? - The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.
SELECT 
    c.first_name, c.last_name, SUM(i.total) AS totalspend
FROM
    customer AS c
        JOIN
    invoice AS i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY totalspend DESC
LIMIT 1;

-- 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A
SELECT DISTINCT
    c.email, c.first_name, c.last_name, g.`name`
FROM
    customer AS c
        JOIN
    invoice AS i ON c.customer_id = i.customer_id
        JOIN
    invoiceline AS il ON i.invoice_id = il.invoice_id
        JOIN
    track AS t ON il.track_id = t.track_id
        JOIN
    genre AS g ON t.genre_id = g.genre_id
WHERE
    g.`name` = 'Rock' AND c.email LIKE 'a%'
ORDER BY c.email;

-- 7. Let's invite the artists who have written the most rock music in our dataset.
-- Write a query that returns the Artist name and total track count of the top 10 rock bands

SELECT 
    a.name, COUNT(t.track_id) AS total_rock_tracks
FROM
    artist AS a
        JOIN
    album AS al ON a.artist_id = al.artist_id
        JOIN
    track AS t ON al.album_id = t.album_id
        JOIN
    genre AS g ON t.genre_id = g.genre_id
WHERE
    g.name = 'Rock'
GROUP BY a.name
ORDER BY total_rock_tracks DESC
LIMIT 10;

-- 8. Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length, with the longest songs listed first

SELECT 
    name, milliseconds
FROM
    Track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds)
        FROM
            Track)
ORDER BY milliseconds DESC;
  
  -- 9. Find how much amount is spent by each customer on artists? 
  -- Write a query to return customer name, artist name and total spent 
SELECT c.First_Name,c.Last_Name,a.`Name` AS ArtistName,
    SUM(il.Unit_Price * il.Quantity) AS TotalSpent
FROM
    Customer AS c
        JOIN
    Invoice AS i ON c.Customer_Id = i.Customer_Id
        JOIN
    InvoiceLine AS il ON i.Invoice_Id = il.Invoice_Id
        JOIN
    Track AS t ON il.Track_Id = t.Track_Id
        JOIN
    Album AS al ON t.Album_Id = al.Album_Id
        JOIN
    Artist AS a ON al.Artist_Id = a.Artist_Id
GROUP BY c.Customer_Id , a.Artist_Id
ORDER BY TotalSpent DESC;
  
  
  -- 10. We want to find out the most popular music Genre for each country. 
  -- We determine the most popular genre as the genre with the highest amount of purchases.
  -- Write a query that returns each country along with the top Genre. 
  -- For countries where the maximum number of purchases is shared, return all Genres
  
WITH CountryGenreSales AS (
  SELECT i.Billing_Country,g.Name AS Genre,SUM(il.Quantity) AS Purchases
  FROM Invoice AS i
  JOIN InvoiceLine AS il ON i.Invoice_Id = il.Invoice_Id
  JOIN Track AS t ON il.Track_Id = t.Track_Id
  JOIN Genre AS g ON t.Genre_Id = g.Genre_Id
  GROUP BY i.Billing_Country,
    g.Name
),
MaxSalesPerCountry AS (
  SELECT Billing_Country,MAX(Purchases) AS MaxPurchases
  FROM CountryGenreSales
  GROUP BY Billing_Country
)
SELECT cgs.Billing_Country,cgs.Genre,cgs.Purchases
FROM
  CountryGenreSales AS cgs
JOIN MaxSalesPerCountry AS msp ON cgs.Billing_Country = msp.Billing_Country
WHERE cgs.Purchases = msp.MaxPurchases
ORDER BY cgs.Billing_Country;
  
  
  -- 11. Write a query that determines the customer that has spent the most on music for each country. 
  -- Write a query that returns the country along with the top customer and how much they spent. 
  -- For countries where the top amount spent is shared, provide all customers who spent this amount

  WITH Customer_Spending AS (
  SELECT i.Billing_Country,
    c.First_Name || ' ' || c.Last_Name AS Customer_Name,
    SUM(i.Total) AS Total_Spent
  FROM Customer AS c
  JOIN Invoice AS i ON c.Customer_Id = i.Customer_Id
  GROUP BY i.Billing_Country,Customer_Name
),
Max_Spending AS (
  SELECT Billing_Country,
  MAX(Total_Spent) AS Max_Total_Spent
  FROM Customer_Spending
  GROUP BY Billing_Country
)
SELECT cs.Billing_Country, cs.Customer_Name,
  cs.Total_Spent
FROM Customer_Spending AS cs
JOIN
  Max_Spending AS ms ON cs.Billing_Country = ms.Billing_Country
WHERE cs.Total_Spent = ms.Max_Total_Spent
ORDER BY cs.Billing_Country;
