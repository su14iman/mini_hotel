
-- neue Datenbank erstellen!
create database mini_hotel;

-- die Datenbank benutzen!
use mini_hotel;


-- User Table.
create table user (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  firstname varchar(50) NOT NULL,
  lastname varchar(50) NOT NULL,
  email varchar(50) NOT NULL,
  password varchar(50) NOT NULL,
  createAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
-- die Daten (user's) einfügen
INSERT INTO user (id, firstname, lastname, email, password, createAt) VALUES 
  (NULL, 'Sulaiman', 'Sulaiman', 's.su14iman@gmail.com', '1231233', CURRENT_TIMESTAMP), 
  (NULL, 'Finnian', 'Richardson', 'finnian@richardson.com', '1231233', CURRENT_TIMESTAMP);


-- Benutzeradresse table!
create table user_address (
  user_id int NOT NULL,
  street varchar(75) NOT NULL,
  house varchar(4) NOT NULL,
  city varchar(50) NOT NULL,
  zipcode varchar(10) NOT NULL,
  state varchar(50) NOT NULL,
  country varchar(50) NOT NULL,
  createAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE
);
-- die Daten (adresse) einfügen
INSERT INTO user_address (user_id, street, house, city, zipcode, state, country, createAt) VALUES 
  ('1', 'Kaiser-karl-ring', '46', 'Bonn', '53119', 'NRW', 'Germany', CURRENT_TIMESTAMP), 
  ('2', 'Waldstrasse', '76', 'Frankfurt am Main', '60528', 'Hesse', 'Germany', CURRENT_TIMESTAMP);


-- Zimmerkategorie table!
create table room_category (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name varchar(10) NOT NULL,
  createAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
-- die Daten (kategorie) einfügen
INSERT INTO room_category (id, name, createAt) VALUES 
  (NULL, 'einzelzimmer', CURRENT_TIMESTAMP), 
  (NULL, 'doppelzimmer', CURRENT_TIMESTAMP);


-- Zimmer table!
create table room (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  roomcategory_id int NOT NULL,
  roomNumber int NULL,
  description text,
  flooer int(2) NOT NULL,
  price float DEFAULT '0',
  createAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (roomcategory_id) REFERENCES room_category(id) ON DELETE CASCADE
);
-- die Daten (zimmer) einfügen
INSERT INTO room (id, roomcategory_id, roomNumber, description, flooer, price, createAt) VALUES 
  (NULL, '1', '212', 'Das Zimmer hat Meerblick.', '2','110', CURRENT_TIMESTAMP), 
  (NULL, '2', '747', 'Das Zimmer ist hell.', '5','150', CURRENT_TIMESTAMP);



-- services table! 
create table service (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name varchar(75) NOT NULL,
  description text,
  price float DEFAULT '0',
  createAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
-- die Daten (services) einfügen
INSERT INTO service (id, name, description, price, createAt) VALUES 
  (NULL, 'Parkplatz', NULL, '0', CURRENT_TIMESTAMP), 
  (NULL, 'Fitnessstudio', NULL, '10', CURRENT_TIMESTAMP), 
  (NULL, 'Sauna', NULL, '15', CURRENT_TIMESTAMP), 
  (NULL, 'Frühstück', NULL, '20', CURRENT_TIMESTAMP);


-- reservierung tabel!
create table reservation (
  id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id int NOT NULL,
  room_id int NOT NULL,
  checkin date NOT NULL,
  checkout date NOT NULL,
  createAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE,
  FOREIGN KEY (room_id) REFERENCES room(id) ON DELETE CASCADE
);
-- die Daten (reservierungen) einfügen
INSERT INTO reservation (id, user_id, room_id, checkin, checkout, createAt) VALUES 
(NULL, '1', '2', '2023-03-28', '2023-03-31', CURRENT_TIMESTAMP), 
(NULL, '2', '1', '2023-03-29', '2023-04-5', CURRENT_TIMESTAMP);


-- Dienstleistungen in Reservierung (reservation_service) table!
create table reservation_service (
  reservation_id int NOT NULL,
  service_id int NOT NULL,
  FOREIGN KEY (reservation_id) REFERENCES reservation (id) ON DELETE CASCADE,
  FOREIGN KEY (service_id) REFERENCES service (id) ON DELETE CASCADE
);
-- die Daten (Dienstleistungen) einfügen
INSERT INTO reservation_service (reservation_id, service_id) VALUES 
  ('1', '4'), 
  ('1', '1'), 
  ('1', '2'), 
  ('2', '1'), 
  ('2', '4');


-- check in / check out tabel!
create table check_log (
  reservation_id int NOT NULL UNIQUE,
  checkin timestamp NOT NULL,
  checkout timestamp NULL DEFAULT NULL,
  status int(1) NOT NULL DEFAULT '0',
  createAt timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (reservation_id) REFERENCES reservation (id) ON DELETE CASCADE
);





-- SELECT Queries:

-- check in 
INSERT INTO check_log (reservation_id, checkin, checkout, status, createAt) VALUES 
('1', NOW(), NULL, '0', CURRENT_TIMESTAMP), 
('2', NOW(), NULL, '0', CURRENT_TIMESTAMP);

-- check out 
UPDATE check_log SET status = 1, checkout = NOW() WHERE reservation_id = 1;


-- alle Zimmer aufrufen.
select * from room;

-- frei Zimmer aufrufen.
select room.id, room.roomNumber, room.flooer, room.price
from room as room
join reservation as reservation
join check_log as log
ON room.id = reservation.room_id
AND reservation.id = log.reservation_id
where log.checkout IS NOT NULL AND log.checkout < NOW();


--  get user reservation with service
select user.id as UserID, user.firstname, user.lastname, reservation.checkin, reservation.checkout,
service.name, service.description, service.price
from user as user
join reservation as reservation
join reservation_service as reservation_service
join service as service
on reservation.user_id = user.id 
AND reservation_service.reservation_id = reservation.id
AND service.id = reservation_service.service_id
WHERE user.id = 1


-- get users conut from germany -> group by
SELECT COUNT(user.id), address.country
from user
join user_address as address
on address.user_id = user.id
GROUP BY address.country;


-- get total price of reservation and services -> sum 
select user.id as UserID, user.firstname, user.lastname, reservation.checkin, reservation.checkout,
SUM(service.price)+room.price as Total
from user as user
join reservation as reservation
join reservation_service as reservation_service
join service as service
join room as room
on reservation.user_id = user.id 
AND reservation.room_id = room.id
AND reservation_service.reservation_id = reservation.id
AND service.id = reservation_service.service_id
WHERE user.id = 1;


-- get services cost -> IN: Mix
SELECT * FROM service 
  WHERE (price) IN ( 
    SELECT MAX(price) FROM service 
  );

-- get services cost -> IN: Min
SELECT * FROM service 
  WHERE (price) IN ( 
    SELECT Min(price) FROM service 
  );