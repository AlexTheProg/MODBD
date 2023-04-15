CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS "user" (
	user_id INTEGER PRIMARY KEY,
	username VARCHAR(50) unique not null,
	password VARCHAR (256) not null,
	first_name VARCHAR(80) not null,
	last_name VARCHAR(80) not null,
	created_by VARCHAR(50) not null,
	created_date TIMESTAMP not null,
	last_modified_by VARCHAR(50) not null,
	last_modified_date TIMESTAMP not null,
	email VARCHAR(100) unique not null,
	workspace_id uuid not null REFERENCES workspace(workspace_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS authority (
	authority_id INTEGER PRIMARY KEY,
	authority_name VARCHAR(50) unique not null
);

CREATE TABLE IF NOT EXISTS user_authority (
	user_id INTEGER not null REFERENCES "user"(user_id) ON DELETE CASCADE,
	authority_id INTEGER not null REFERENCES authority(authority_id) ON DELETE CASCADE,
	CONSTRAINT user_authority_pkey PRIMARY KEY (user_id, authority_id)
);

CREATE TABLE IF NOT EXISTS workspace (
	workspace_id uuid PRIMARY KEY,
	workspace_name VARCHAR(100) UNIQUE NOT NULL,
	description VARCHAR(255) UNIQUE NOT NULL,
	region VARCHAR(2) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS document (
	document_id INTEGER PRIMARY KEY,
	document_uri VARCHAR(256) UNIQUE not null,
	user_id INTEGER not null REFERENCES "user"(user_id),
	workspace_id uuid not null REFERENCES workspace(workspace_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS task (
	task_id INTEGER PRIMARY KEY,
	name VARCHAR(50),
	type VARCHAR(15),
	start_date TIMESTAMP,
	close_date TIMESTAMP,
	status VARCHAR(15),
	user_id INTEGER not null REFERENCES "user"(user_id)
);

CREATE TABLE IF NOT EXISTS deal (
	deal_id INTEGER PRIMARY KEY,
	name VARCHAR(50) UNIQUE,
	status VARCHAR(15),
	description VARCHAR(255)
);


CREATE TABLE IF NOT EXISTS user_deal (
	user_id INTEGER not null REFERENCES "user"(user_id),
	deal_id INTEGER not null REFERENCES deal(deal_id),
	CONSTRAINT user_deal_pkey PRIMARY KEY (user_id, deal_id)
);

CREATE TABLE IF NOT EXISTS company (
	company_id INTEGER PRIMARY KEY,
	name VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS contact (
	contact_id INTEGER PRIMARY KEY,
	first_name VARCHAR(50) not null,
	last_name VARCHAR(50) not null,
	user_id INTEGER REFERENCES "user"(user_id),
	company_id INTEGER REFERENCES company(company_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS country (
	country_id INTEGER PRIMARY KEY,
	country_name VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS address (
	address_id INTEGER PRIMARY KEY,
	unit_number VARCHAR(5),
	street_number INTEGER,
	address_line_1 TEXT,
	address_line_2 TEXT,
	city VARCHAR(25),
	region VARCHAR(25),
	postal_code VARCHAR(10),
	country_id INTEGER REFERENCES country(country_id) ON DELETE CASCADE,
	workspace_id uuid REFERENCES workspace(workspace_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS company_address (
	company_id INTEGER REFERENCES company(company_id),
	address_id INTEGER REFERENCES address(address_id),
	CONSTRAINT company_address_pkey PRIMARY KEY(company_id, address_id)
);

---sequences for the id's---
---doc, task, deal, country, address, company, contact 
CREATE SEQUENCE IF NOT EXISTS user_sequence INCREMENT 1 START 1 OWNED BY "user".user_id;
CREATE SEQUENCE IF NOT EXISTS authority_sequence INCREMENT 1 START 1 OWNED BY authority.authority_id;
CREATE SEQUENCE IF NOT EXISTS deal_sequence INCREMENT 1 START 1 OWNED BY deal.deal_id;
CREATE SEQUENCE IF NOT EXISTS document_sequence INCREMENT 1 START 1 OWNED BY document.document_id;
CREATE SEQUENCE IF NOT EXISTS task_sequence INCREMENT 1 START 1 OWNED BY task.task_id;
CREATE SEQUENCE IF NOT EXISTS company_sequence INCREMENT 1 START 1 OWNED BY company.company_id;
CREATE SEQUENCE IF NOT EXISTS contact_sequence INCREMENT 1 START 1 OWNED BY contact.contact_id;
CREATE SEQUENCE IF NOT EXISTS country_sequence INCREMENT 1 START 1 OWNED BY country.country_id;
