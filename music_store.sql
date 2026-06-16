create database project;
use project;
CREATE TABLE Genre ( 
genre_id INT PRIMARY KEY, 
name VARCHAR(120) 
); 
select * from genre;
select * from MediaType;
CREATE TABLE MediaType ( 
media_type_id INT PRIMARY KEY, 
name VARCHAR(120) 
);
select * from Employee;
CREATE TABLE Employee ( 
 employee_id INT PRIMARY KEY, 
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
 customer_id INT PRIMARY KEY, 
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
); 
select * from customer;
 -- 4. Artist 
CREATE TABLE Artist ( 
 artist_id INT PRIMARY KEY, 
 name VARCHAR(120) 
); 
select * from Artist;
 -- 5. Album 
CREATE TABLE Album ( 
 album_id INT PRIMARY KEY, 
 title VARCHAR(800), 
 artist_id INT, 
 FOREIGN KEY (artist_id) REFERENCES Artist(artist_id) 
); 
drop database project;
select * from album;
 -- 6. Track 
CREATE TABLE Track (
track_id INT PRIMARY KEY, 
 name VARCHAR(200), 
 album_id INT, 
 media_type_id INT, 
 genre_id INT, 
 composer VARCHAR(220), 
 milliseconds INT, 
 bytes INT, 
 unit_price DECIMAL(10,2), 
 FOREIGN KEY (album_id) REFERENCES Album(album_id), 
 FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id), 
 FOREIGN KEY (genre_id) REFERENCES Genre(genre_id) 
); 

 -- 7. Invoice 
CREATE TABLE Invoice ( 
 invoice_id INT PRIMARY KEY, 
 customer_id INT, 
 invoice_date DATE, 
 billing_address VARCHAR(255), 
 billing_city VARCHAR(100), 
 billing_state VARCHAR(100), 
 billing_country VARCHAR(100), 
 billing_postal_code VARCHAR(20), 
 total DECIMAL(10,2), 
 FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) 
); 

 -- 8. InvoiceLine 
CREATE TABLE InvoiceLine ( 
 invoice_line_id INT PRIMARY KEY, 
 invoice_id INT, 
 track_id INT, 
 unit_price DECIMAL(10,2), 
 quantity INT, 
 FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id), 
 FOREIGN KEY (track_id) REFERENCES Track(track_id) 
); 
 -- 9. Playlist 
CREATE TABLE Playlist ( 
  playlist_id INT PRIMARY KEY, 
 name VARCHAR(255) 
); 
 -- 10. PlaylistTrack 
CREATE TABLE PlaylistTrack ( 
 playlist_id INT, 
 track_id INT, 
 PRIMARY KEY (playlist_id, track_id), 
 FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id), 
 FOREIGN KEY (track_id) REFERENCES Track(track_id) 
);
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/track.csv'
INTO TABLE  track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price);


select * from employee;
-- 1. Who is the senior most employee based on job title?  
SELECT 
    employee_id, last_name, first_name, title, levels
FROM
    employee
ORDER BY levels DESC
LIMIT 1;

-- 2. Which countries have the most Invoices? 
SELECT 
    billing_country, COUNT(*)
FROM
    invoice
GROUP BY billing_country
ORDER BY COUNT(*) DESC;

-- 3. What are the top 3 values of total invoice? 
SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3;

-/* 4. Which city has the best customers? - We would like to throw a promotional Music Festival in 
the city we made the most money. Write a query that returns one city that has the highest sum of 
invoice totals. Return both the city name & sum of all invoice totals */

SELECT billing_city, SUM(total)
FROM invoice
GROUP BY billing_city
ORDER BY SUM(total) DESC
LIMIT 1;

/* 5. Who is the best customer? - The customer who has spent the most money will be declared 
the best customer. Write a query that returns the person who has spent the most money */

SELECT 
    c.customer_id, c.first_name, SUM(i.total)
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id , c.first_name
ORDER BY SUM(i.total) DESC
LIMIT 1;

/* 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A */

SELECT 
    c.email, c.first_name, c.last_name, g.name
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
        JOIN
    invoiceline il ON i.invoice_id = il.invoice_id
        JOIN
    track t ON il.track_id = t.track_id
        JOIN
    genre g ON t.genre_id = g.genre_id
WHERE
    g.name = 'Rock'
ORDER BY c.email;

/* 7. Let's invite the artists who have written the most rock music in our dataset. Write a query that 
returns the Artist name and total track count of the top 10 rock bands  */

SELECT 
    ar.name, COUNT(t.track_id)
FROM
    artist ar
        JOIN
    album al ON ar.artist_id = al.artist_id
        JOIN
    track t ON al.album_id = t.album_id
        JOIN
    genre g ON t.genre_id = g.genre_id
WHERE
    g.name = 'rock'
GROUP BY ar.name
ORDER BY COUNT(t.track_id) DESC;

/*8. Return all the track names that have a song length longer than the average song length.- 
Return the Name and Milliseconds for each track. Order by the song length, with the longest 
songs listed first*/

SELECT name, milliseconds
FROM track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds)
        FROM
            track)
ORDER BY milliseconds DESC;


/* 9. Find how much amount is spent by each customer on artists? Write a query to return 
customer name, artist name and total spent  */

SELECT 
    c.first_name, ar.name, SUM(il.unit_price) AS total_spent
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
        JOIN
    invoiceline il ON i.invoice_id = il.invoice_id
        JOIN
    track t ON il.track_id = t.track_id
        JOIN
    album al ON t.album_id = al.album_id
        JOIN
    artist ar ON al.artist_id = ar.artist_id
GROUP BY c.customer_id , ar.artist_id
ORDER BY total_spent DESC;



select * from artist;
select*from customer;
select * from album;
select * from track;
select * from employee;
select * from invoice;

select * from invoiceline;
select * from artist;

