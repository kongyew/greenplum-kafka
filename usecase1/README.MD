# Pivotal Greenplum
The Pivotal Greenplum Database (GPDB) is an advanced, fully featured, open source data warehouse. It provides powerful and rapid analytics on petabyte scale data volumes. Uniquely geared toward big data analytics, Greenplum Database is powered by the world’s most advanced cost-based query optimizer delivering high analytical query performance on large data volumes.
<https://pivotal.io/pivotal-greenplum>

# How to use Greenplum to load data from Kafka

This [repository](https://github.com/kongyew/greenplum-kafka) demonstrates how to use gpKafka to read  data from Kafka.

# Table of Contents
1. [Pre-requisites](#Pre-requisites)
2. [Start Docker-compose](#Start-Docker-compose)
3. [Configure Greenplum](#Configure-Greenplum)
4. [Configure Kafka](#Configure-Kafka)



## Pre-requisites:
- [docker-compose](http://docs.docker.com/compose)
- [Kafka docker image](https://hub.docker.com/u/confluentinc/)
- [GPDB 5.x OSS docker image](https://hub.docker.com/r/kochanpivotal/gpdb5oss/)

## Start Docker-compose
Once you have cloned this repository, you can run the command  `./runDocker.sh -t usecase1 -c up`, in order to start both Greenplum and Kafka docker instances.

The assumption: docker and docker-compose are already installed on your machine.

### Run command to start both Greenplum and Kafka instances
```
$ ./runDocker.sh -t usecase1 -c up
WARNING: Found orphan containers (postgresql) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.
Recreating gpdbsne ... done
gpdbsne     | /etc/sysconfig/run-parts
gpdbsne     | /usr/bin/run-parts
gpdbsne     | Running /docker-entrypoint.d
gpdbsne     | /docker-entrypoint.d/startInit.sh:
gpdbsne     |
gpdbsne     | init is running
gpdbsne     | /docker-entrypoint.d/startSSH.sh:
```

### How to access Greenplum docker instance:
You can use this command `docker exec -it gpdbsne bin/bash` to access Greenplum docker instance.

For example:
```
$ docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS                                                                                             NAMES
80f13a74b2e7        confluentinc/cp-kafka:4.0.0       "/etc/confluent/dock…"   About an hour ago   Up About an hour    0.0.0.0:9092->9092/tcp                                                                                                               kafka
e56cfb32a775        kochanpivotal/gpdb5-pxf           "/docker-entrypoint.…"   About an hour ago   Up About an hour    0.0.0.0:5005->5005/tcp, 0.0.0.0:5010->5010/tcp, 0.0.0.0:5432->5432/tcp, 0.0.0.0:40000-40002->40000-40002/tcp, 0.0.0.0:9022->22/tcp   gpdbsne
9e74d2173a7f        confluentinc/cp-zookeeper:4.0.0   "/etc/confluent/dock…"   About an hour ago   Up About an hour    2888/tcp, 0.0.0.0:2181->2181/tcp, 3888/tcp                                                                                           zookeeper                                                                       gpdbsne
root@gpdbsne:/#

```
### How to access Kafka docker instance:
You can use this command `docker exec -it Kafka bin/bash` to access Kafka docker instance.

For example:
```
$ docker exec -it Kafka bin/bash
[root@kafka /]#
```

## Configure Greenplum
Once you have access to Greenplum docker instance, you can create database, table.

1. Use `su - gpadmin` to create table. The setupDB.sh script is located under `/code/gpkafka/setuptable` folder.
````
[gpadmin@gpdbsne ~]$ cd /code/gpkafka/
[gpadmin@gpdbsne gpkafka]$ ls
loadcfg1.yaml  loadcfg.yaml  setuptable
[gpadmin@gpdbsne gpkafka]$ cd setuptable
[gpadmin@gpdbsne setuptable]$ ./setupDB.sh
psql:./sample_table.sql:1: NOTICE:  schema "payables" does not exist, skipping
DROP SCHEMA
CREATE SCHEMA
psql:./sample_table.sql:3: NOTICE:  table "expenses" does not exist, skipping
DROP TABLE
psql:./sample_table.sql:5: NOTICE:  Table doesn't have 'DISTRIBUTED BY' clause -- Using column named 'id' as the Greenplum Database data distribution key for this table.
HINT:  The 'DISTRIBUTED BY' clause determines the distribution of data. Make sure column(s) chosen are the optimal data distribution key to minimize skew.
CREATE TABLE
[gpadmin@gpdbsne setuptable]$
```
2. Verify the number of records in this table  `payables.expenses` in database `payables_db`
```
[gpadmin@gpdbsne setuptable]$ psql -d payables_db;
psql (8.3.23)
Type "help" for help.

payables_db=# select count(*) from payables.expenses;
 count
-------
     0
(1 row)

payables_db=#
```


## Configure Kafka
This section describes how to setup Kafka.

### Setup example data on Kafka
1. You can use this command `docker exec -it Kafka bin/bash` to access Kafka docker instance.
For example:
```
$ docker exec -it Kafka bin/bash
[root@Kafka /]#
```
2. This script `create_topic.sh` creates sample data for this topic "topic_for_gpkafka".
```
[root@kafka:/# cd /code/kafka
root@kafka:/code/kafka# ls
consume_data.sh  create_topic.sh  produce_100data.sh  produce_data.sh  quickstart  sample_data.csv
root@kafka:/code/kafka# ./create_topic.sh
WARNING: Due to limitations in metric names, topics with a period ('.') or underscore ('_') could collide. To avoid issues it is best to use either, but not both.
Created topic "topic_for_gpkafka".
```
3. Run this script '/code/kafka/produce_100data.sh ' to generate data

```
root@kafka:/code/kafka# ls
consume_data.sh  create_topic.sh  produce_100data.sh  produce_data.sh  quickstart  sample_data.csv
root@kafka:/code/kafka# ./produce_100data.sh
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
```

## How to use gpkafka to load data from Kafka
Make sure you are accessing GPDB docker instance.
1. Use `docker exec -it gpdbsne bin/bash` to access GPDB instance.
2. Run gpkafka to start the data loading process.
Make sure you run this command `export PGPASSWORD=pivotal` to set the password.
Next, you run this command `gpkafka load ./loadcfg.yaml` to begin data loading process.

```
[gpadmin@gpdbsne ~]$ cd /code/gpkafka/
.DS_Store      loadcfg1.yaml  loadcfg.yaml   setuptable/    
[gpadmin@gpdbsne gpkafka]$ export PGPASSWORD=pivotal
[gpadmin@gpdbsne gpkafka]$ gpkafka load ./loadcfg.yaml
20180727:23:51:54.928 gpkafkaload:gpadmin:gpdbsne:000635-[INFO]:- /tmp/build/057f7d3c/gopath/src/github.com/greenplum-db/gpss/utils/gpfdist/gpfdist.go:64: gpfdist listening on gpdbsne:8080
20180727:23:51:55.043 gpkafkaload:gpadmin:gpdbsne:000635-[INFO]:- /tmp/build/057f7d3c/gopath/src/github.com/greenplum-db/gpss/kafkaload/kafkareader.go:229: partition num=1
20180727:23:51:55.161 gpkafkaload:gpadmin:gpdbsne:000635-[INFO]:- /tmp/build/057f7d3c/gopath/src/github.com/greenplum-db/gpss/kafkaload/kafkareader.go:50: Worker:0 set topic 'topic_for_gpkafka', partition 0, offset 0
20180727:23:51:55.175 gpkafkaload:gpadmin:gpdbsne:000635-[INFO]:- /tmp/build/057f7d3c/gopath/src/github.com/greenplum-db/gpss/kafkaload/job.go:144: Start batch 0
20180727:23:51:55.288 gpkafkaload:gpadmin:gpdbsne:000635-[INFO]:- /tmp/build/057f7d3c/gopath/src/github.com/greenplum-db/gpss/kafkaload/job.go:153: Batch flow read 1000 rows in 30 ms
20180727:23:51:55.288 gpkafkaload:gpadmin:gpdbsne:000635-[INFO]:- /tmp/build/057f7d3c/gopath/src/github.com/greenplum-db/gpss/kafkaload/job.go:154: End batch 0: load 1000 rows
20180727:23:51:55.288 gpkafkaload:gpadmin:gpdbsne:000635-[INFO]:- /tmp/build/057f7d3c/gopath/src/github.com/greenplum-db/gpss/kafkaload/job.go:144: Start batch 1
20180727:23:51:55.337 gpkafkaload:gpadmin:gpdbsne:000635-[INFO]:- /tmp/build/057f7d3c/gopath/src/github.com/greenplum-db/gpss/kafkaload/kafkareader.go:106: Kafka read worker 0 EOF reached, offset 1052, 3 rows left
20180727:23:51:56.792 gpkafkaload:gpadmin:gpdbsne:000635-[INFO]:- /tmp/build/057f7d3c/gopath/src/github.com/greenplum-db/gpss/kafkaload/kafkareader.go:106: Kafka read worker 0 EOF reached, offset 1061, 9 rows left
20180727:23:51:58.800 gpkafkaload:gpadmin:gpdbsne:000635-[INFO]:- /tmp/build/057f7d3c/gopath/src/github.com/greenplum-db/gpss/kafkaload/kafkareader.go:106: Kafka read worker 0 EOF reached, offset 1070, 9 rows left
```


## How to verify the commits by gpkafka
Make sure you are accessing GPDB docker instance.

1. Use `gpkafka check ./loadcfg.yaml `
````
[gpadmin@gpdbsne gpkafka]$ cd /code/gpkafka
[gpadmin@gpdbsne gpkafka]$ gpkafka check ./loadcfg.yaml
PartitionID	StartTime	EndTime	BeginOffset	EndOffset
0	2018-07-27T23:54:25Z	2018-07-27T23:54:25Z	1728	1800
[gpadmin@gpdbsne gpkafka]$
```



## How to use PSQL to access data that is written by gpkafka
Make sure you are accessing GPDB docker instance.

1. Use psql on GPDB docker instance to access payables_db.
````
[gpadmin@gpdbsne setuptable]$ psql -d payables_db;
psql (8.3.23)
Type "help" for help.

payables_db=# select count(*) from payables.expenses;
 count
-------
     0
(1 row)

payables_db=#
```

2. Verify the number of records in this table payables.expenses
```
[gpadmin@gpdbsne setuptable]$ psql -d payables_db;
psql (8.3.23)
Type "help" for help.

payables_db=# select count(*) from payables.expenses;
 count
-------
     0
(1 row)

payables_db=#
```





# Reference:
[Greenplum product]: https://pivotal.io/pivotal-greenplum
[Greenplum documentations]: https://https://gpdb.docs.pivotal.io/


# Reference:
[How to setup GPHDFS for GPDB 5.x](https://gpdb.docs.pivotal.io/570/admin_guide/external/g-using-hadoop-distributed-file-system--hdfs--tables.html)
