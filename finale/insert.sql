INSERT INTO region(region_id, region_name) VALUES (1,'EU');
INSERT INTO region(region_id, region_name) VALUES (2,'AS');
INSERT INTO region(region_id, region_name) VALUES (3,'NA');
INSERT INTO region(region_id, region_name) VALUES (4,'OCE');


-- select gen_random_uuid();

INSERT INTO new_workspace(
    workspace_id, workspace_name, description, region_id)
VALUES ('327330b3-059f-4af8-931e-64b2ac68b315', 'EU_new_workspace', 'new_workspace dedicated to the European region', 1);

INSERT INTO new_workspace(
    workspace_id, workspace_name, description, region_id)
VALUES ('b08f78bb-694d-4093-b0e4-e9dbf943fd4a', 'AS_new_workspace', 'new_workspace dedicated to the Asiatic region', 2);

INSERT INTO new_workspace(
    workspace_id, workspace_name, description, region_id)
VALUES ('f6b23d3a-e19a-4807-ab71-90b48ba3d108', 'NA_new_workspace', 'new_workspace dedicated to the North American region', 3);

INSERT INTO new_workspace(
    workspace_id, workspace_name, description, region_id)
VALUES ('3b939294-41e1-432b-99ab-35d8bba020eb', 'OCE_new_workspace', 'new_workspace dedicated to the Oceanic region', 4);



INSERT INTO workspace(
    workspace_id, workspace_name, description, region)
VALUES ('327330b3-059f-4af8-931e-64b2ac68b315', 'EU_new_workspace', 'new_workspace dedicated to the European region', 1);

INSERT INTO workspace(
    workspace_id, workspace_name, description, region)
VALUES ('b08f78bb-694d-4093-b0e4-e9dbf943fd4a', 'AS_new_workspace', 'new_workspace dedicated to the Asiatic region', 2);

INSERT INTO workspace(
    workspace_id, workspace_name, description, region)
VALUES ('f6b23d3a-e19a-4807-ab71-90b48ba3d108', 'NA_new_workspace', 'new_workspace dedicated to the North American region', 3);

INSERT INTO workspace(
    workspace_id, workspace_name, description, region)
VALUES ('3b939294-41e1-432b-99ab-35d8bba020eb', 'OCE_new_workspace', 'new_workspace dedicated to the Oceanic region', 4);



INSERT INTO company(company_id, name) VALUES (1, 'Mobexpert');
INSERT INTO company(company_id, name) VALUES (2, 'Enel');
INSERT INTO company(company_id, name) VALUES (3, 'Orange');
INSERT INTO company(company_id, name) VALUES (4, 'Telekom');
INSERT INTO company(company_id, name) VALUES (5, 'Bavaria');
INSERT INTO company(company_id, name) VALUES (6, 'Telekom');
INSERT INTO company(company_id, name) VALUES (7, 'Autoklass');
INSERT INTO company(company_id, name) VALUES (8, 'Romstal');
INSERT INTO company(company_id, name) VALUES (9, 'Novum');
INSERT INTO company(company_id, name) VALUES (10, 'Activator Hub');

INSERT INTO country(country_id, country_name) VALUES (1, 'Germany');
INSERT INTO country(country_id, country_name) VALUES (2, 'Australia');
INSERT INTO country(country_id, country_name) VALUES (3, 'China');
INSERT INTO country(country_id, country_name) VALUES (4, 'Japan');
INSERT INTO country(country_id, country_name) VALUES (5, 'Canada');
INSERT INTO country(country_id, country_name) VALUES (6, 'Mexico');
INSERT INTO country(country_id, country_name) VALUES (7, 'USA');
INSERT INTO country(country_id, country_name) VALUES (8, 'Romania');
INSERT INTO country(country_id, country_name) VALUES (9, 'New Zaeland');
INSERT INTO country(country_id, country_name) VALUES (10, 'Norway');


INSERT INTO address(
    address_id,unit_number,street_number,address_line_1,address_line_2,
    city,region,postal_code,country_id, workspace_id)
VALUES (1, 3, 67, 'Lalelelor', 'Str. Gheorghe Adagiu', 'Bucuresti', 'EU', '854336', 8, '327330b3-059f-4af8-931e-64b2ac68b315');
INSERT INTO address(
    address_id,unit_number,street_number,address_line_1,address_line_2,
    city,region,postal_code,country_id, workspace_id)
VALUES (2, 3, 4, 'Newman Dawr', 'Leibzahn Cohen', 'Berlin', 'EU', '234356', 1, '327330b3-059f-4af8-931e-64b2ac68b315');
INSERT INTO address(
    address_id,unit_number,street_number,address_line_1,address_line_2,
    city,region,postal_code,country_id, workspace_id)
VALUES (3, 2, 56, 'Dweitzburg', 'Ashburry Alley', 'Sydney', 'OCE', '854336', 2, '3b939294-41e1-432b-99ab-35d8bba020eb');
INSERT INTO address(
    address_id,unit_number,street_number,address_line_1,address_line_2,
    city,region,postal_code,country_id, workspace_id)
VALUES (4, 1, 102, 'Zing Zao', 'Douyong Khan', 'Beijing', 'AS', '99974', 3, 'b08f78bb-694d-4093-b0e4-e9dbf943fd4a');
INSERT INTO address(
    address_id,unit_number,street_number,address_line_1,address_line_2,
    city,region,postal_code,country_id, workspace_id)
VALUES (5, 13, 457, 'Yonge', 'Denzels Den' , 'Otawa', 'NA', '343445', 5, 'f6b23d3a-e19a-4807-ab71-90b48ba3d108');
INSERT INTO address(
    address_id,unit_number,street_number,address_line_1,address_line_2,
    city,region,postal_code,country_id, workspace_id)
VALUES (6, 4, 99, 'Tan Teriaki', 'Gangnam To', 'Tokyo', 'AS', '6665', 4, 'b08f78bb-694d-4093-b0e4-e9dbf943fd4a');
INSERT INTO address(
    address_id,unit_number,street_number,address_line_1,address_line_2,
    city,region,postal_code,country_id, workspace_id)
VALUES (7, 2, 44, 'Park Avenue', '5th Avenue', 'New York', 'NA', '2343', 7, 'f6b23d3a-e19a-4807-ab71-90b48ba3d108');
INSERT INTO address(
    address_id,unit_number,street_number,address_line_1,address_line_2,
    city,region,postal_code,country_id, workspace_id)
VALUES (8, 6, 23, 'Van Dingo', 'Dolores', 'New Mexico', 'NA', '27643', 6, 'f6b23d3a-e19a-4807-ab71-90b48ba3d108');
INSERT INTO address(
    address_id,unit_number,street_number,address_line_1,address_line_2,
    city,region,postal_code,country_id, workspace_id)
VALUES (9, 3, 134, 'Varanderin', 'Konliig Schohn', 'Oslo', 'EU', '5356', 10, '327330b3-059f-4af8-931e-64b2ac68b315');
INSERT INTO address(
    address_id,unit_number,street_number,address_line_1,address_line_2,
    city,region,postal_code,country_id, workspace_id)
VALUES (10, 6, 98, 'Beach Road', 'George Kassaway', 'Wellington', 'OCE', '98765', 9, '3b939294-41e1-432b-99ab-35d8bba020eb');



INSERT INTO "user"(user_id, username, password, first_name, last_name, created_by,
                   created_date, last_modified_by, last_modified_date, email, workspace_id)
VALUES (1, 'iorganda_paul', 'parola123', 'Paul', 'Iorganda', 'admin',
        '2017-03-31 09:30:20-07',  'admin', '2020-08-23 08:20:11-07', 'iorganda_paul@gmail.com',
        '327330b3-059f-4af8-931e-64b2ac68b315');

INSERT INTO "user"(user_id, username, password, first_name, last_name, created_by,
                   created_date, last_modified_by, last_modified_date, email, workspace_id)
VALUES (2, 'jashin_dao', 'suashsu382', 'Dao', 'Jashin', 'admin',
        '2018-01-04 11:20:30-07',  'admin', '2022-08-23 11:20:30-07', 'jashin_dao@gmail.com',
        'b08f78bb-694d-4093-b0e4-e9dbf943fd4a');

INSERT INTO "user"(user_id, username, password, first_name, last_name, created_by,
                   created_date, last_modified_by, last_modified_date, email, workspace_id)
VALUES (3, 'thompshon_john', 'fhussd9874', 'John', 'Thompson', 'admin',
        '2015-09-20 09:30:20-07',  'admin', '2027-08-22 08:20:11-08', 'thompshon_john@gmail.com',
        'f6b23d3a-e19a-4807-ab71-90b48ba3d108');

INSERT INTO "user"(user_id, username, password, first_name, last_name, created_by,
                   created_date, last_modified_by, last_modified_date, email, workspace_id)
VALUES (4, 'audrey_peter', 'pass334789', 'Peter', 'Audrey', 'admin',
        '2015-12-12 09:30:20-07',  'admin', '2021-07-11 08:20:11-08', 'audrey_peter@gmail.com',
        '3b939294-41e1-432b-99ab-35d8bba020eb');



INSERT INTO document(document_id, document_uri, user_id, workspace_id)
VALUES (1,'https://region-code.crm.com/key-name/Doc4567.pdf',4,'3b939294-41e1-432b-99ab-35d8bba020eb');

INSERT INTO document(document_id, document_uri, user_id, workspace_id)
VALUES (2,'https://region-code.crm.com/key-name/Doc368.pdf',2,'b08f78bb-694d-4093-b0e4-e9dbf943fd4a');

INSERT INTO document(document_id, document_uri, user_id, workspace_id)
VALUES (3,'https://region-code.crm.com/key-name/Doc2112.pdf',3,'f6b23d3a-e19a-4807-ab71-90b48ba3d108');

INSERT INTO document(document_id, document_uri, user_id, workspace_id)
VALUES (4,'https://region-code.crm.com/key-name/Doc9868.pdf',1,'327330b3-059f-4af8-931e-64b2ac68b315');


INSERT INTO contact(contact_id, first_name, last_name, user_id, company_id)
VALUES(1,'Paul', 'Iorganda', 1, 3);

INSERT INTO contact(contact_id, first_name, last_name, user_id, company_id)
VALUES(2,'Dao', 'Jashin', 2, 2);

INSERT INTO contact(contact_id, first_name, last_name, user_id, company_id)
VALUES(3,'John', 'Thompson', 3, 6);

INSERT INTO contact(contact_id, first_name, last_name, user_id, company_id)
VALUES(4,'Peter', 'Audrey', 4, 7);


INSERT INTO company_address(company_id, address_id) VALUES(1,1);
INSERT INTO company_address(company_id, address_id) VALUES(2,2);
INSERT INTO company_address(company_id, address_id) VALUES(3,3);
INSERT INTO company_address(company_id, address_id) VALUES(4,4);
INSERT INTO company_address(company_id, address_id) VALUES(5,5);
INSERT INTO company_address(company_id, address_id) VALUES(6,6);
INSERT INTO company_address(company_id, address_id) VALUES(7,7);
INSERT INTO company_address(company_id, address_id) VALUES(8,8);
INSERT INTO company_address(company_id, address_id) VALUES(9,9);
INSERT INTO company_address(company_id, address_id) VALUES(10,10);


INSERT INTO authority(authority_id, authority_name) VALUES(1, 'admin');
INSERT INTO authority(authority_id, authority_name) VALUES(2, 'user');
INSERT INTO authority(authority_id, authority_name) VALUES(3, 'owner');

INSERT INTO deal(deal_id, name, status, description) VALUES(1,'sale','done','Sale bussiness deal');
INSERT INTO deal(deal_id, name, status, description) VALUES(2,'hire','pending','Hire services deal');


INSERT INTO task(task_id, name, type, start_date, close_date, status, user_id)
VALUES(1,'Front-end interface','development','2015-12-12 08:00:00-07','2016-06-27 18:00:00-07','done',1);

INSERT INTO task(task_id, name, type, start_date, close_date, status, user_id)
VALUES(2,'Back-end planning','coordination','2016-03-12 08:00:00-07','2016-11-27 18:00:00-07','done',2);

INSERT INTO task(task_id, name, type, start_date, close_date, status, user_id)
VALUES(3,'Front-end bug-fixing','testing','2016-06-28 08:00:00-07','2017-06-23 18:00:00-07','done',3);

INSERT INTO task(task_id, name, type, start_date, close_date, status, user_id)
VALUES(4,'Back-end bug-fixing','testing','2016-12-12 08:00:00-07','2017-06-12 18:00:00-07','done',4);

INSERT INTO user_authority(user_id, authority_id) VALUES(1,3);
INSERT INTO user_authority(user_id, authority_id) VALUES(2,1);
INSERT INTO user_authority(user_id, authority_id) VALUES(3,2);
INSERT INTO user_authority(user_id, authority_id) VALUES(4,2);

INSERT INTO user_deal(user_id, deal_id) VALUES(1,1);
INSERT INTO user_deal(user_id, deal_id) VALUES(2,2);
INSERT INTO user_deal(user_id, deal_id) VALUES(3,2);
INSERT INTO user_deal(user_id, deal_id) VALUES(4,1);


select * from authority;
SELECT * FROM company_address;
select * from contact;
select * from document;
select * from "user";
select * from region;
select * from company;
select * from country;
select * from region;
select * from new_workspace;
select * from address;

