CREATE EXTENSION IF NOT EXISTS postgres_fdw;

---fragmentarea orizontala primara
CREATE TABLE IF NOT EXISTS workspace_eu
(
    workspace_id   uuid PRIMARY KEY,
    workspace_name VARCHAR(100) NOT NULL,
    description    VARCHAR(255) NOT NULL,
    region_id      INTEGER      NOT NULL
);

---fragmentarea orizontala derivata
---de schimbat cu datele serverului pe care s-au rulat init + fragmentare

CREATE SERVER Global_Server FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'host.docker.internal', port '5432', dbname 'postgres');

CREATE USER MAPPING IF NOT EXISTS for "postgres"
    SERVER Global_Server OPTIONS (user 'postgres', password 'pass');

CREATE FOREIGN TABLE "user_global" (
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
    SERVER Global_Server
    OPTIONS (table_name 'user');

SELECT *
FROM user_global;
SELECT *
FROM user_eu;

CREATE TABLE user_eu
AS
SELECT *
FROM user_global u
WHERE EXISTS
          (SELECT 1
           FROM workspace_eu w
           WHERE u.workspace_id = w.workspace_id
          );

INSERT INTO "user_global" (user_id, username, password, first_name, last_name, created_by, created_date,
                           last_modified_by, last_modified_date, email, workspace_id)
VALUES (5, 'Local EU USER', 'password', 'first_name', 'last_name', 'created_by', '2016-06-22 19:10:25-07',
        'last_modified_by', '2016-06-22 19:10:25-07', 'emailL', 'edb32df8-a961-4569-8bff-b5711886ce9a');


INSERT INTO "user_eu" (user_id, username, password, first_name, last_name, created_by, created_date, last_modified_by,
                       last_modified_date, email, workspace_id)
VALUES (6, 'Local EU USER6', 'password', 'first_name', 'last_name', 'created_by', '2016-06-22 19:10:25-07',
        'last_modified_by', '2016-06-22 19:10:25-07', 'emailL6', 'edb32df8-a961-4569-8bff-b5711886ce9a');

