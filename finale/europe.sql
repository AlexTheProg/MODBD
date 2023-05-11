CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- 2. Fragmentare orizontala primara
CREATE TABLE IF NOT EXISTS workspace_eu (
	workspace_id uuid PRIMARY KEY,
	workspace_name VARCHAR(100) NOT NULL,
	description VARCHAR(255) NOT NULL,
	region_id INTEGER NOT NULL
);

-- 2. Fragmentare orizontala derivata
-- cream o legatura cu tabelul user din serverul global
CREATE SERVER Global_Server FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'host.docker.internal', port '5432', dbname 'postgres');

CREATE USER MAPPING IF NOT EXISTS for "postgres" 
SERVER Global_Server OPTIONS (user 'postgres', password 'pass');

CREATE FOREIGN TABLE "user_global" (
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
SERVER Global_Server
OPTIONS (table_name 'user');

-- selectam valorile pentru europa din global
CREATE TABLE user_eu AS
SELECT *
	FROM   user_global  u
	WHERE  EXISTS
	(SELECT 1	
	 FROM   workspace_eu w
	 WHERE u.workspace_id = w.workspace_id 
	);


-- 4. Furnizarea formelor de transparență pentru întreg modelul ales
-- 4.c 

-- procedura pentru inregistrarile din serverul curent
CREATE OR REPLACE PROCEDURE delete_user_eu(given_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
   DELETE FROM user_eu WHERE user_id = given_id;
END;
$$;

CALL delete_user_eu(6);
DROP procedure delete_user_eu


-- procedura pentru inregistrarile din alt server
CREATE SERVER Asia FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'host.docker.internal', port '5434', dbname 'postgres');

CREATE USER MAPPING IF NOT EXISTS for "postgres" 
SERVER Asia OPTIONS (user 'postgres', password 'alex1999');

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

CREATE OR REPLACE PROCEDURE delete_user_as(given_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
   DELETE FROM user_as WHERE user_id = given_id;
END;
$$;

CALL delete_user_as(7);
