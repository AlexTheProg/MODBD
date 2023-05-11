---fragmentare orizontala primara (sharding dupa region din workspace)
---postgresql foloseste FDW pentru distribuire (Foreign Data Wrappers)
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE INDEX IF NOT EXISTS workspace_index ON workspace (workspace_id);

explain analyze
select *
from workspace;

CREATE TABLE region
(
    region_id   INTEGER PRIMARY KEY,
    region_name VARCHAR(5) unique not null
);



CREATE SEQUENCE IF NOT EXISTS region_sequence INCREMENT 1 START 1 OWNED BY region.region_id;

ALTER TABLE workspace
    ADD COLUMN region_id INTEGER REFERENCES region (region_id);
ALTER TABLE workspace
    DROP COLUMN region;

---vom face sharding-ul (fragmentarea orizontala primara dupa campul region_id).
---exista EU, NA, AS, OCE (4 regiuni) si vom face fragmentarea dupa restul
---impartirii la 4 al FOREIGN KEY-ului din tabelul workspace. De
---aici rezulta ca vom avea 4 shard-uri (servere)
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

---prepare the foreign table
CREATE TABLE IF NOT EXISTS new_workspace
(
    workspace_id   uuid,
    workspace_name VARCHAR(100) NOT NULL,
    description    VARCHAR(255) NOT NULL,
    region_id      INTEGER
) PARTITION BY RANGE (region_id);


CREATE FOREIGN TABLE workspace_oce PARTITION OF new_workspace FOR VALUES FROM (0) TO (10) SERVER Oceania;
CREATE FOREIGN TABLE workspace_na PARTITION OF new_workspace FOR VALUES FROM (10) TO (20) SERVER North_America;
CREATE FOREIGN TABLE workspace_as PARTITION OF new_workspace FOR VALUES FROM (20) TO (30) SERVER Asia;
CREATE FOREIGN TABLE workspace_eu PARTITION OF new_workspace FOR VALUES FROM (30) TO (40) SERVER Europe;



select *
from new_workspace;
select *
from workspace_eu;


---fragmentare orizontala derivata

CREATE FOREIGN TABLE "user_eu" (
    user_id INTEGER,
    username VARCHAR(50) not null,
    password VARCHAR(256) not null,
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

select *
from "user";
select *
from "user_eu";
INSERT INTO "user" (user_id, username, password, first_name, last_name, created_by, created_date, last_modified_by,
                    last_modified_date, email, workspace_id)
VALUES (3, 'username3', 'password', 'first_name', 'last_name', 'created_by', '2016-06-22 19:10:25-07',
        'last_modified_by', '2016-06-22 19:10:25-07', 'email3', '69ff6e53-747c-4fbb-b097-2be11600e376');

-- 4. Transaparenta
-- Transaparenta fragmentare origontala primara

create or replace view workspaces
as
select *
from new_workspace;

SELECT *
FROM workspaces;

-- nu avem nevoie de trigeri pt ca shardingul facut deja insereaza inregistrarile in tabelul extern corect

INSERT INTO workspaces(workspace_id, workspace_name, description, region_id)
VALUES (gen_random_uuid(), 'EU_Workspace1', 'Eu_Description1', 39);


-- Transaparenta fragmentare origontala derivata
create or replace view "users"
as
select *
from "user_eu";

SELECT *
FROM "users";

--
-- DROP trigger users_trigger ON users;
CREATE OR REPLACE FUNCTION users_trigger_fn() RETURNS TRIGGER AS
$$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF (SELECT 1 FROM workspace_eu WHERE workspace_id = NEW.workspace_id) THEN
            insert into user_eu
            values (NEW.user_id, NEW.username, NEW.password, NEW.first_name, NEW.last_name, NEW.created_by,
                    NEW.created_date, NEW.last_modified_by, NEW.last_modified_date, NEW.email, NEW.workspace_id);
        END IF;
    END IF;
    IF (TG_OP = 'UPDATE') THEN
        IF (SELECT 1 FROM workspace_eu WHERE workspace_id = NEW.workspace_id) THEN
            update user_eu
                values
            SET user_id=NEW.user_id,
                username=NEW.username,
                password=NEW.password,
                first_name=NEW.first_name,
                last_name=NEW.last_name,
                created_by=NEW.created_by,
                created_date=NEW.created_date,
                last_modified_by=NEW.last_modified_by,
                last_modified_date=NEW.last_modified_date,
                email=NEW.email,
                workspace_id=NEW.workspace_id
            WHERE user_id = NEW.user_id;
        END IF;
    END IF;
    IF (TG_OP = 'DELETE') THEN
        IF (SELECT 1 FROM workspace_eu WHERE workspace_id = NEW.workspace_id) THEN
            DELETE
            FROM user_eu
            WHERE user_id = NEW.user_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_trigger
    INSTEAD OF INSERT OR UPDATE
    ON users
    FOR EACH ROW
EXECUTE FUNCTION users_trigger_fn();

INSERT INTO "users" (user_id, username, password, first_name, last_name, created_by, created_date, last_modified_by,
                     last_modified_date, email, workspace_id)
VALUES (5, 'EU USER2', 'password', 'first_name', 'last_name', 'created_by', '2016-06-22 19:10:25-07',
        'last_modified_by', '2016-06-22 19:10:25-07', 'email5', 'edb32df8-a961-4569-8bff-b5711886ce9a');

DELETE
FROM users
WHERE user_id = 5;
