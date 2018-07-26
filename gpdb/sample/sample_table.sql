
drop table if exists basic;
create table basic (
	id	bigint,
	col1 	text,
	col2	float4
) distributed by (id);


INSERT INTO basic VALUES (1, 'TEXT_1',  1);
INSERT INTO basic VALUES (2, 'TEXT_2',  2);
INSERT INTO basic VALUES (4, 'TEXT_3',  3);
INSERT INTO basic VALUES (5, 'TEXT_4',  4);
INSERT INTO basic VALUES (6, 'TEXT_5',  5);
INSERT INTO basic VALUES (6, 'TEXT_5',  5);

drop table if exists basic2;
create table basic2 (
	id	bigint,
	coltext 	text,
	coldatetime	Date
) distributed by (id);


INSERT INTO basic2 (id, coltext, coldatetime) VALUES (1, 'San Francisco', '1994-11-29');
INSERT INTO basic2 (id, coltext, coldatetime) VALUES (2, 'San Jose', '2004-11-29');
INSERT INTO basic2 (id, coltext, coldatetime) VALUES (3, 'San Mateo', '2014-11-29');

drop table if exists gpdbsink;
create table gpdbsink (
	id serial,
	value text
) distributed by (id);

insert into gpdbsink (value) values ('Alice');
insert into gpdbsink (value) values ('Bob');
insert into gpdbsink (value) values ('Charlie');
insert into gpdbsink (value) values ('Eve');

insert into gpdbsink (value) select value from gpdbsink;
insert into gpdbsink (value) select value from gpdbsink;
insert into gpdbsink (value) select value from gpdbsink;
insert into gpdbsink (value) select value from gpdbsink;
insert into gpdbsink (value) select value from gpdbsink;

insert into gpdbsink (value) select value from gpdbsink;
insert into gpdbsink (value) select value from gpdbsink;
insert into gpdbsink (value) select value from gpdbsink;
insert into gpdbsink (value) select value from gpdbsink;
insert into gpdbsink (value) select value from gpdbsink;

insert into gpdbsink (value) select value from gpdbsink;
insert into gpdbsink (value) select value from gpdbsink;
insert into gpdbsink (value) select value from gpdbsink;
insert into gpdbsink (value) select value from gpdbsink;
insert into gpdbsink (value) select value from gpdbsink;

-- CREATE DATABASE IF NOT EXISTS connect_test;
-- USE connect_test;


DROP TABLE IF EXISTS test;
CREATE TABLE  test (
  id serial NOT NULL PRIMARY KEY,
  name varchar(100),
  email varchar(200),
  department varchar(200),
  modified timestamp default CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX modified_index
ON test (modified);

INSERT INTO test (name, email, department) VALUES ('alice', 'alice@abc.com', 'engineering');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
