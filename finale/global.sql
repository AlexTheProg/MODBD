-- 1. Creearea bazei de date

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS workspace (
    workspace_id uuid PRIMARY KEY,
    workspace_name VARCHAR(100) UNIQUE NOT NULL,
    description VARCHAR(255) UNIQUE NOT NULL,
    region VARCHAR(2) UNIQUE NOT NULL
);

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


-- 2. Crearea relațiilor și a fragmentelor
-- 2.a fragmentare orizontala primara
-- postgresql foloseste FDW pentru distribuire (Foreign Data Wrappers)

CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE INDEX IF NOT EXISTS workspace_index ON workspace(workspace_id);

explain analyze select * from workspace;

CREATE TABLE region (
	region_id INTEGER PRIMARY KEY,
	region_name VARCHAR(5) unique not null
);

CREATE SEQUENCE IF NOT EXISTS region_sequence INCREMENT 1 START 1 OWNED BY region.region_id;

ALTER TABLE workspace ADD COLUMN region_id INTEGER REFERENCES region(region_id);
ALTER TABLE workspace DROP COLUMN region;

---vom face sharding-ul (fragmentarea orizontala primara dupa campul region_id).
---exista EU, NA, AS, OCE (4 regiuni) si vom face fragmentarea dupa impartirea
---valorilor FOREIGN KEY-ului region_id in 4 intervale.
---De aici rezulta ca vom avea 4 shard-uri (servere)

CREATE SERVER Europe FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', port '5437', dbname 'postgres');

CREATE SERVER North_America FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', port '5435', dbname 'postgres');

CREATE SERVER Asia FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', port '5434', dbname 'postgres');

CREATE SERVER Oceania FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', port '5436', dbname 'postgres');

CREATE USER MAPPING IF NOT EXISTS for "postgres" 
SERVER Europe OPTIONS (user 'postgres', password 'alex1999');

CREATE USER MAPPING IF NOT EXISTS for "postgres" 
SERVER Asia OPTIONS (user 'postgres', password 'alex1999');

CREATE USER MAPPING IF NOT EXISTS for "postgres" 
SERVER North_America OPTIONS (user 'postgres', password 'alex1999');

CREATE USER MAPPING IF NOT EXISTS for "postgres" 
SERVER Oceania OPTIONS (user 'postgres', password 'alex1999');

CREATE TABLE IF NOT EXISTS new_workspace (
	workspace_id uuid,
	workspace_name VARCHAR(100) NOT NULL,
	description VARCHAR(255) NOT NULL,
	region_id INTEGER
) PARTITION BY RANGE (region_id);


CREATE FOREIGN TABLE workspace_oce PARTITION OF new_workspace FOR VALUES FROM (0) TO (10) SERVER Oceania;
CREATE FOREIGN TABLE workspace_na PARTITION OF new_workspace FOR VALUES FROM (10) TO (20) SERVER North_America;
CREATE FOREIGN TABLE workspace_as PARTITION OF new_workspace FOR VALUES FROM (20) TO (30) SERVER Asia;
CREATE FOREIGN TABLE workspace_eu PARTITION OF new_workspace FOR VALUES FROM (30) TO (40) SERVER Europe;


-- 4 Furnizarea formelor de transparență pentru întreg modelul ales
-- 4.b transparență pentru fragmentele orizontale

-- view fragmentarea primitiva
create or replace view workspaces
as
select * from new_workspace;

-- transparenta fragmentarea derivata
--Cream conexiuni la tabelele user_** ale celorlalte servere
CREATE FOREIGN TABLE "user_eu" (
	user_id INTEGER,
	username VARCHAR(50) not null,
	password VARCHAR (256) not null,
	first_name VARCHAR(80) not null,
	last_name VARCHAR(80) not null,
	created_by VARCHAR(50) not null,
	created_date TIMESTAMP not null,
	last_modified_by VARCHAR(50) not null,
	last_modified_date TIMESTAMP not null,
	email VARCHAR(100) not null,
	workspace_id uuid not null
)
SERVER Europe
OPTIONS (table_name 'user_eu');

CREATE FOREIGN TABLE "user_as" (
	user_id INTEGER,
	username VARCHAR(50) not null,
	password VARCHAR (256) not null,
	first_name VARCHAR(80) not null,
	last_name VARCHAR(80) not null,
	created_by VARCHAR(50) not null,
	created_date TIMESTAMP not null,
	last_modified_by VARCHAR(50) not null,
	last_modified_date TIMESTAMP not null,
	email VARCHAR(100) not null,
	workspace_id uuid not null
)
SERVER Asia
OPTIONS (table_name 'user_as');

CREATE FOREIGN TABLE "user_na" (
	user_id INTEGER,
	username VARCHAR(50) not null,
	password VARCHAR (256) not null,
	first_name VARCHAR(80) not null,
	last_name VARCHAR(80) not null,
	created_by VARCHAR(50) not null,
	created_date TIMESTAMP not null,
	last_modified_by VARCHAR(50) not null,
	last_modified_date TIMESTAMP not null,
	email VARCHAR(100) not null,
	workspace_id uuid not null
)
SERVER North_America
OPTIONS (table_name 'user_na');

CREATE FOREIGN TABLE "user_oce" (
	user_id INTEGER,
	username VARCHAR(50) not null,
	password VARCHAR (256) not null,
	first_name VARCHAR(80) not null,
	last_name VARCHAR(80) not null,
	created_by VARCHAR(50) not null,
	created_date TIMESTAMP not null,
	last_modified_by VARCHAR(50) not null,
	last_modified_date TIMESTAMP not null,
	email VARCHAR(100) not null,
	workspace_id uuid not null
)
SERVER Oceania
OPTIONS (table_name 'user_oce');

create or replace view "users"
as
select * from "user_eu"
union all
select * from "user_as"
union all
select * from "user_na"
union all
select * from "user_oce";

--trigger care asigura inserarea datelor in fragmentul bun 
CREATE OR REPLACE FUNCTION users_trigger_fn() RETURNS TRIGGER AS $$
BEGIN
IF (TG_OP = 'INSERT') THEN
    IF (SELECT 1 FROM workspace_eu WHERE workspace_id = NEW.workspace_id) THEN
        insert into user_eu
         values (NEW.user_id, NEW.username, NEW.password, NEW.first_name, NEW.last_name, NEW.created_by, NEW.created_date, NEW.last_modified_by, NEW.last_modified_date, NEW.email, NEW.workspace_id);
    END IF;
	    IF (SELECT 1 FROM workspace_as WHERE workspace_id = NEW.workspace_id) THEN
        insert into user_as
         values (NEW.user_id, NEW.username, NEW.password, NEW.first_name, NEW.last_name, NEW.created_by, NEW.created_date, NEW.last_modified_by, NEW.last_modified_date, NEW.email, NEW.workspace_id);
    END IF;
	IF (SELECT 1 FROM workspace_na WHERE workspace_id = NEW.workspace_id) THEN
        insert into user_na
         values (NEW.user_id, NEW.username, NEW.password, NEW.first_name, NEW.last_name, NEW.created_by, NEW.created_date, NEW.last_modified_by, NEW.last_modified_date, NEW.email, NEW.workspace_id);
    END IF;

END IF;
IF (TG_OP = 'UPDATE') THEN
    IF (SELECT 1 FROM workspace_eu WHERE workspace_id = NEW.workspace_id) THEN
        update user_eu
        values SET user_id=NEW.user_id, username=NEW.username, password=NEW.password, first_name=NEW.first_name, last_name=NEW.last_name, created_by=NEW.created_by, created_date=NEW.created_date, 
			last_modified_by=NEW.last_modified_by, last_modified_date=NEW.last_modified_date, email=NEW.email, workspace_id=NEW.workspace_id
		WHERE user_id = NEW.user_id;	
    END IF;
	    IF (SELECT 1 FROM workspace_as WHERE workspace_id = NEW.workspace_id) THEN
        update user_as
        values SET user_id=NEW.user_id, username=NEW.username, password=NEW.password, first_name=NEW.first_name, last_name=NEW.last_name, created_by=NEW.created_by, created_date=NEW.created_date, 
			last_modified_by=NEW.last_modified_by, last_modified_date=NEW.last_modified_date, email=NEW.email, workspace_id=NEW.workspace_id
		WHERE user_id = NEW.user_id;	
    END IF;
	IF (SELECT 1 FROM workspace_na WHERE workspace_id = NEW.workspace_id) THEN
        update user_na
        values SET user_id=NEW.user_id, username=NEW.username, password=NEW.password, first_name=NEW.first_name, last_name=NEW.last_name, created_by=NEW.created_by, created_date=NEW.created_date, 
			last_modified_by=NEW.last_modified_by, last_modified_date=NEW.last_modified_date, email=NEW.email, workspace_id=NEW.workspace_id
		WHERE user_id = NEW.user_id;	
    END IF;
	    IF (SELECT 1 FROM workspace_oce WHERE workspace_id = NEW.workspace_id) THEN
        update user_oce
        values SET user_id=NEW.user_id, username=NEW.username, password=NEW.password, first_name=NEW.first_name, last_name=NEW.last_name, created_by=NEW.created_by, created_date=NEW.created_date, 
			last_modified_by=NEW.last_modified_by, last_modified_date=NEW.last_modified_date, email=NEW.email, workspace_id=NEW.workspace_id
		WHERE user_id = NEW.user_id;	
    END IF;
END IF;
IF (TG_OP = 'DELETE') THEN
    IF (SELECT 1 FROM workspace_eu WHERE workspace_id = NEW.workspace_id) THEN
        DELETE FROM user_eu
        WHERE user_id = NEW.user_id;	
    END IF;
	    IF (SELECT 1 FROM workspace_as WHERE workspace_id = NEW.workspace_id) THEN
        DELETE FROM user_as
        WHERE user_id = NEW.user_id;	
    END IF;
	IF (SELECT 1 FROM workspace_na WHERE workspace_id = NEW.workspace_id) THEN
        DELETE FROM user_na
        WHERE user_id = NEW.user_id;	
    END IF;
	IF (SELECT 1 FROM workspace_oce WHERE workspace_id = NEW.workspace_id) THEN
        DELETE FROM user_oce
        WHERE user_id = NEW.user_id;	
    END IF;
END IF;	
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_trigger
INSTEAD OF INSERT OR UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION users_trigger_fn();

