---fragmentare orizontala primara (sharding dupa region din workspace)
---postgresql foloseste FDW pentru distribuire (Foreign Data Wrappers)
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
---exista EU, NA, AS, OCE (4 regiuni) si vom face fragmentarea dupa restul
---impartirii la 4 al FOREIGN KEY-ului din tabelul workspace. De
---aici rezulta ca vom avea 4 shard-uri (servere)
CREATE SERVER Europe FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', port '5433', dbname 'EuropeMODBD');

CREATE SERVER North_America FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', port '5433', dbname 'NAMODBD');

CREATE SERVER Asia FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', port '5433', dbname 'AsiaMODBD');

CREATE SERVER Oceania FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', port '5433', dbname 'OceaniaMODBD');

CREATE USER MAPPING IF NOT EXISTS for "postgres" 
SERVER Europe OPTIONS (user 'postgres', password 'alex1999');

CREATE USER MAPPING IF NOT EXISTS for "postgres" 
SERVER Asia OPTIONS (user 'postgres', password 'alex1999');

CREATE USER MAPPING IF NOT EXISTS for "postgres" 
SERVER North_America OPTIONS (user 'postgres', password 'alex1999');

CREATE USER MAPPING IF NOT EXISTS for "postgres" 
SERVER Oceania OPTIONS (user 'postgres', password 'alex1999');

---prepare the foreign table
CREATE TABLE IF NOT EXISTS new_workspace (
	workspace_id uuid,
	workspace_name VARCHAR(100) NOT NULL,
	description VARCHAR(255) NOT NULL,
	region_id INTEGER
) PARTITION BY HASH (region_id);

CREATE FOREIGN TABLE workspace_eu PARTITION OF new_workspace FOR VALUES WITH (modulus 4, remainder 3) SERVER Europe;
CREATE FOREIGN TABLE workspace_as PARTITION OF new_workspace FOR VALUES WITH (modulus 4, remainder 2) SERVER Asia;
CREATE FOREIGN TABLE workspace_na PARTITION OF new_workspace FOR VALUES WITH (modulus 4, remainder 1) SERVER North_America;
CREATE FOREIGN TABLE workspace_oce PARTITION OF new_workspace FOR VALUES WITH (modulus 4, remainder 0) SERVER Oceania;

select * from new_workspace;
select * from new_workspace where region_id = 1;
select * from new_workspace where region_id = 2;
select * from new_workspace where region_id = 3;
select * from new_workspace where region_id = 4;



