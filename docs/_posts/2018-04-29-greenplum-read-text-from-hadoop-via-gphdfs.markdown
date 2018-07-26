---
layout: post
title:  "Using gphdfs to read text file from Hadoop into Greenplum!"
date:   2018-04-20 14:54:07 -0700
categories: greenplum hadoop cloudera gphdfs
---


# How to use Greenplum (GPHDFS to read data from Hadoop (Cloudera)

This [repository](https://github.com/kongyew/greenplum-gphdfs-examples) demonstrates how to use GPHDFS to read text data from hadoop.

# Table of Contents
1. [Pre-requisites](#Pre-requisites)
2. [Starting Docker-compose](#Starting Docker-compose)
3. [Configure Greenplum](#Configure Greenplum)
4. [Configure Cloudera](#Configure-Cloudera)



## Pre-requisites:
- [docker-compose](http://docs.docker.com/compose)
- [Cloudera docker image](https://hub.docker.com/r/cloudera/quickstart/)
- [GPDB 5.x OSS docker image](https://hub.docker.com/r/kochanpivotal/gpdb5oss/)

## Starting Docker-compose
Once you have cloned this repository, you can run the command  `./runDocker.sh -t usecase1 -c up`, in order to start both Greenplum and Streamsets docker instances.

The assumption: docker and docker-compose are already installed on your machine.

### Run command to start both Greenplum and Cloudera instances
```
$ ./runDocker.sh -t usecase1 -c up
WARNING: Found orphan containers (postgresql) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.
Recreating gpdbsne ... done
Recreating quickstart.cloudera ... done
Attaching to gpdbsne, quickstart.cloudera
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
06ed0ead09fd        cloudera/quickstart:latest   "/usr/bin/docker-qui…"   3 minutes ago       Up 4 minutes        0.0.0.0:2181->2181/tcp, 0.0.0.0:7077->7077/tcp, 0.0.0.0:7180->7180/tcp, 0.0.0.0:8020->8020/tcp, 0.0.0.0:8042->8042/tcp, 0.0.0.0:8080->8080/tcp, 0.0.0.0:8088->8088/tcp, 0.0.0.0:8888->8888/tcp, 0.0.0.0:8983->8983/tcp, 0.0.0.0:9090->9090/tcp, 0.0.0.0:9092->9092/tcp, 0.0.0.0:10002->10002/tcp, 0.0.0.0:11000->11000/tcp, 0.0.0.0:11443->11443/tcp, 0.0.0.0:16000-16001->16000-16001/tcp, 0.0.0.0:19888->19888/tcp, 0.0.0.0:50070->50070/tcp, 0.0.0.0:60010->60010/tcp, 0.0.0.0:8022->22/tcp, 0.0.0.0:42222->22/tcp, 0.0.0.0:9080->80/tcp   quickstart.cloudera
22c87a7bc39d        kochanpivotal/gpdb5-pxf      "/docker-entrypoint.…"   4 minutes ago       Up 4 minutes        0.0.0.0:5005->5005/tcp, 0.0.0.0:5010->5010/tcp, 0.0.0.0:5432->5432/tcp, 0.0.0.0:40000-40002->40000-40002/tcp, 0.0.0.0:9022->22/tcp                                                                               gpdbsne

root@gpdbsne:/#

```

### How to access Cloudera docker instance:
You can use this command `docker exec -it quickstart.cloudera bin/bash` to access Cloudera docker instance.

For example:
```
$ docker exec -it quickstart.cloudera bin/bash
[root@quickstart /]#
```

## Configure Greenplum
Once you have access to Greenplum docker instance, you can create database, table with some sample data.

1. Start GPDB instance:
Use the command 'startGPDB.sh'
```
root@gpdbsne# startGPDB.sh
SSHD isn't running
 * Starting OpenBSD Secure Shell server sshd                             [ OK ]
SSHD is running...
20180419:21:15:09:000094 gpstart:gpdbsne:gpadmin-[INFO]:-Starting gpstart with args: -a
20180419:21:15:09:000094 gpstart:gpdbsne:gpadmin-[INFO]:-Gathering information and validating the environment...
...
20180419:21:15:18:000247 gpstart:gpdbsne:gpadmin-[INFO]:-Have lock file /tmp/.s.PGSQL.5432 and a process running on port 5432
20180419:21:15:18:000247 gpstart:gpdbsne:gpadmin-[ERROR]:-gpstart error: Master instance process running
```
2. Download Hadoop distribution and [configure Greenplum to use Hadoop distribution](https://gpdb.docs.pivotal.io/570/admin_guide/external/g-one-time-hdfs-protocol-installation.html).

Or you can use these scripts to automate the setup process.

#### Download Hadoop files
This script downloads hadoop tar file and unzip the file on the local directory. You can manually select different hadoop distributions by editing VERSION.
```
[gpadmin@gpdbsne setup]$ ./DownloadHadoopTarGz.sh
Using ./HADOOP
--2018-05-07 22:13:49--  http://apache.claz.org/hadoop/common/hadoop-2.7.6/hadoop-2.7.6.tar.gz
Resolving apache.claz.org (apache.claz.org)... 216.245.218.171
Connecting to apache.claz.org (apache.claz.org)|216.245.218.171|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 216745683 (207M) [application/x-gzip]
Saving to: './HADOOP/hadoop-2.7.6.tar.gz.2'

17% [======>                                ] 38,927,384  9.53MB/s  eta 21s  
```
#### Setup Hadoop files

This script install the hadoop files under /usr/local/hadoop
```
[gpadmin@gpdbsne setup]$ ./SetupHadoopTarGz.sh
Using ./HADOOP
CreateHadoopDir:  ./HADOOP/hadoop-2.7.6.tar.gz
```

#### Setup Hadoop distribution and Hadoop setting for Greenplum, and setup Java

This script install the hadoop files under /usr/local/hadoop
```
[gpadmin@gpdbsne setup]$ ./SetupGPHDFS.sh -i cdh5
export HADOOP_USER_NAME=gpadmin
export PATH=/usr/local/greenplum-db/./bin:/usr/local/greenplum-db/./ext/python/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:.:/sbin:/bin
SSHD is running
export HADOOP_USER_NAME=gpadmin
Using delaybeforesend 0.05 and prompt_validation_timeout 1.0

[Reset ...]
[INFO] login gpdbsne
[gpdbsne] echo 'export HADOOP_USER_NAME=gpadmin' >> /home/gpadmin/.bash_profile
[INFO] completed successfully
...
[Reset ...]
[INFO] login gpdbsne
[gpdbsne] gpconfig -s gp_hadoop_target_version
[gpdbsne] Values on all segments are consistent
[gpdbsne] GUC          : gp_hadoop_target_version
[gpdbsne] Master  value: mpr
[gpdbsne] Segment value: mpr
[INFO] completed successfully
```

##### Create sample database with the name "gphdfs_db"
The scripts to create database and sample data is found at `/code/usercase1/data`.

Next, run the command '/code/usecase1/data/setupDB.sh'
```
[gpadmin@gpdbsne gphdfs]$ ./setupDB.sh           
GRANT
GRANT
CREATE EXTERNAL TABLE
```

3. Verify database and table is created.
Use the command `su - gpadmin`, followed by `psql -U gpadmin -d gphdfs_db -c "select count(*) from gphdfs_hdfs_textsimple;"`.  The result shows no records are yet created.
Example:
```
root@gpdbsne:/code/usecase1/data#su - gpadmin
$
$ psql -U gpadmin -d gphdfs_db -c "select count(*) from gphdfs_hdfs_textsimple;"
 count
-------
     0
(1 row)
```
## Configure Cloudera
This section describes how to setup Cloudera.




### Setup example data on cloudera
1. You can use this command `docker exec -it quickstart.cloudera bin/bash` to access Cloudera docker instance.
For example:
```
$ docker exec -it quickstart.cloudera bin/bash
[root@quickstart /]#
```
2. This script `setupHdfsTextSimpleExample.sh` creates sample text file.
```
[root@quickstart cloudera]# cd /code/usecase1/cloudera
[root@quickstart cloudera]#[root@quickstart cloudera]# ./setupHdfsTextSimpleExample.sh
Using root to run this script.
Found hadoop /data directory
Recursively delete files under /data
Deleted /data
## gphdfs_hdfs_simple.txt is created under this directory /data/gphdfs_examples/
Found 1 items
-rw-r--r--   1 root supergroup        100 2018-05-07 22:29 /data/gphdfs_examples/gphdfs_hdfs_simple.txt
[root@quickstart cloudera]#
```

## How to use PSQL to read data via GPHDFS
Make sure you are accessing GPDB docker instance.

1. Use psql on GPDB docker instance
````
[gpadmin@gpdbsne gphdfs]$
hdfs_textsimple; gphdfs]$ psql -U gpadmin -d gphdfs_db -c "select * from gphdfs_hdfs_textsimple;"
location   | month | num_orders | total_sales
-------------+-------+------------+-------------
Prague      | Jan   |        101 |     4875.33
 Rome      | Mar   |         87 |     1557.39
 Bangalore | May   |        317 |     8936.99
 Beijing   | Jul   |        411 |    11600.67
(4 rows)
```

2. Verify the number of records in this table gphdfs_hdfs_textsimple
```
hdfs_textsimple; gphdfs]$ psql -U gpadmin -d gphdfs_db -c "select count(*) from gphdfs_hdfs_textsimple;"
count
-------
    4
(1 row)
```
# Reference:
[Greenplum product]: https://pivotal.io/pivotal-greenplum
[Greenplum documentations]: https://https://gpdb.docs.pivotal.io/
