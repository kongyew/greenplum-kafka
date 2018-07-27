DROP SCHEMA IF EXISTS payables;
CREATE SCHEMA payables;
DROP TABLE IF EXISTS payables.expenses;

CREATE TABLE payables.expenses( id int8, month int2, expenses decimal(9,2) );
