DROP TABLE IF EXISTS users ;
CREATE TABLE users ( id serial not null primary key, name VARCHAR(100) NOT NULL, age integer,salary decimal);

DROP TABLE IF EXISTS department ;
CREATE TABLE department ( id serial not null primary key,user_id integer, name VARCHAR(100) NOT NULL, loc VARCHAR(100));