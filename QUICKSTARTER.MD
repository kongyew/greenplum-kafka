# Quick Start:
This quick start provides a basic guide for deploying a Kafka cluster with Greenplum cluster in your Docker environment. By the end of this quickstart, you can use Apache Kafka to perform ETL processing data into Greenplum cluster.

By default, the configuration is using docker-compose to create multiple docker instances including Kafka, Zookeeper, Schema Registry and Greenplum. This default setup can be reused for multiple use cases. For more advanced environments, you can create copies of this docker-compose. The example uses Docker external volumes to mount directories on your host machine.

# Prerequisites
1. Docker installed and running.


## Installing & Running Docker
You can use Docker Compose or Docker client.

Getting Started with Docker Compose
Getting Started with Docker Client
Getting Started with Docker Compose
Docker Compose is a powerful tool that enables you to launch multiple Docker images in a coordinated fashion. It is ideal for platforms like Confluent. Before you get started, you will need to install both the core Docker Engine and Docker Compose. Once you’ve done that, you can follow the steps below to start up the Confluent Platform services.

Create and configure the Docker Machine.

Important: If you are using Docker for Mac or Docker for Windows, you can skip this step.

docker-machine create --driver virtualbox --virtualbox-memory 6000 confluent
Next, configure your terminal window to attach it to your new Docker Machine:

eval $(docker-machine env confluent)
Clone the Confluent Platform Docker Images Github Repository.

git clone https://github.com/confluentinc/cp-docker-images
An example Docker Compose file is included that will start up ZooKeeper and Kafka. Navigate to cp-docker-images/examples/kafka-single-node, where it is located. Alternatively, you can download the file directly from GitHub.

Start the ZooKeeper and Kafka containers in detached mode (-d). Run this command from the directory that contains the docker-compose.yml file. For example, use this path to launch a single node environment:

cd <path-to-cp-docker-images>/examples/kafka-single-node/
docker-compose up -d
You should see the following:

Pulling kafka (confluentinc/cp-kafka:latest)...
latest: Pulling from confluentinc/cp-kafka
ad74af05f5a2: Already exists
d02e292e7b5e: Already exists
8de7f5c81ab0: Already exists
ed0b76dc2730: Already exists
cfc44fa8a002: Already exists
f441b84ed9ba: Already exists
d42bb38e2f0e: Already exists
Digest: sha256:61373cf6eca980887164d6fede2552015db31a809c99d6c3d5dfc70867b6cd2d
Status: Downloaded newer image for confluentinc/cp-kafka:latest
Creating kafkasinglenode_zookeeper_1 ...
Creating kafkasinglenode_zookeeper_1 ... done
Creating kafkasinglenode_kafka_1 ...
Creating kafkasinglenode_kafka_1 ... done
Tip: You can run this command to verify that the services are up and running:

docker-compose ps
You should see the following:

           Name                        Command            State   Ports
-----------------------------------------------------------------------
kafkasinglenode_kafka_1       /etc/confluent/docker/run   Up
kafkasinglenode_zookeeper_1   /etc/confluent/docker/run   Up
If the state is not Up, rerun the docker-compose up -d command.

Now check the ZooKeeper logs to verify that ZooKeeper is healthy.

docker-compose logs zookeeper | grep -i binding
You should see the following:

zookeeper_1  | [2016-07-25 03:26:04,018] INFO binding to port 0.0.0.0/0.0.0.0:32181 (org.apache.zookeeper.server.NIOServerCnxnFactory)
Next, check the Kafka logs to verify that broker is healthy.

docker-compose logs kafka | grep -i started
You should see the following:

kafka_1      | [2017-08-31 00:31:40,244] INFO [Socket Server on Broker 1], Started 1 acceptor threads (kafka.network.SocketServer)
kafka_1      | [2017-08-31 00:31:40,426] INFO [Replica state machine on controller 1]: Started replica state machine with initial state -> Map() (kafka.controller.ReplicaStateMachine)
kafka_1      | [2017-08-31 00:31:40,436] INFO [Partition state machine on Controller 1]: Started partition state machine with initial state -> Map() (kafka.controller.PartitionStateMachine)
kafka_1      | [2017-08-31 00:31:40,540] INFO [Kafka Server 1], started (kafka.server.KafkaServer)
Test the broker by following these instructions.

Now you can take this basic deployment for a test drive. You’ll verify that the broker is functioning normally by creating a topic and producing data to it. You’ll use the client tools directly from another Docker container.

Create a topic named foo and keep things simple by just giving it one partition and one replica. For a production environment you would have many more broker nodes, partitions, and replicas for scalability and resiliency.

docker-compose exec kafka  \
kafka-topics --create --topic foo --partitions 1 --replication-factor 1 --if-not-exists --zookeeper localhost:32181
You should see the following:

Created topic "foo".
Verify that the topic was created successfully:

docker-compose exec kafka  \
  kafka-topics --describe --topic foo --zookeeper localhost:32181
You should see the following:

Topic:foo   PartitionCount:1    ReplicationFactor:1 Configs:
Topic: foo  Partition: 0    Leader: 1    Replicas: 1  Isr: 1
Publish some data to your new topic. This command uses the built-in Kafka Console Producer to produce 42 simple messages to the topic.

docker-compose exec kafka  \
  bash -c "seq 42 | kafka-console-producer --request-required-acks 1 --broker-list localhost:29092 --topic foo && echo 'Produced 42 messages.'"
After running the command, you should see the following:

Produced 42 messages.
Read back the message using the built-in Console consumer:

docker-compose exec kafka  \
  kafka-console-consumer --bootstrap-server localhost:29092 --topic foo --from-beginning --max-messages 42
If everything is working as expected, each of the original messages you produced should be written back out:

1
....
42
Processed a total of 42 messages
You must explicitly shut down Docker Compose. For more information, see the [docker-compose down](https://docs.docker.com/compose/reference/down/) documentation. This will delete all of the containers that you created in this quickstart.

docker-compose down
The confluentinc/cp-docker-images GitHub repository has several other interesting examples of docker-compose.yml files that you can use.

Getting Started with Docker Client
Note

The following steps show each Docker container being launched in detached mode and how to access the logs for those detached containers. If you prefer to run the containers in the foreground, you can do so by replacing the -d (“detached”) flag with --it (“interactive”). Containers launched in interactive mode will stream the log messages for the Confluent service directly to the terminal window. For that reason, you’ll need a separate terminal for each Docker image launched in interactive mode.

Create and configure the Docker Machine. This example creates a VirtualBox VM with ~6 GB of memory to serve as your Docker host.

$ docker-machine create --driver virtualbox --virtualbox-memory 6000 confluent
Note

If you want to reuse a Docker Machine you’ve already created under the name “confluent” run: docker-machine start confluent instead.

Next, configure your terminal window to attach it to your new Docker Machine:

$ eval $(docker-machine env confluent)
All of the subsequent commands should be run from that terminal window to ensure proper access to the running Docker host. To execute Docker commands from a new terminal window, simply execute the eval $(docker-machine env confluent) first.

ZooKeeper
Start ZooKeeper. You’ll need to keep this service running throughout, so use a dedicated terminal window if you plan to launch the image in the foreground.

$ docker run -d \
    --net=host \
    --name=zookeeper \
    -e ZOOKEEPER_CLIENT_PORT=32181 \
    confluentinc/cp-zookeeper:4.0.0
This command instructs Docker to launch an instance of the confluentinc/cp-zookeeper:4.0.0 container and name it zookeeper. We also specify that we want to use host networking and pass in the required parameter for running Zookeeper: ZOOKEEPER_CLIENT_PORT. For a full list of the available configuration options and more details on passing environment variables into Docker containers, see the configuration reference docs.

Use the following command to check the Docker logs to confirm that the container has booted up successfully and started the ZooKeeper service.

$ docker logs zookeeper
With this command, you’re referencing the container name that you want to see the logs for. To list all containers (running or failed), you can always run docker ps -a. This is especially useful when running in detached mode.

When you output the logs for ZooKeeper, you should see the following message at the end of the log output:

[2016-07-24 05:15:35,453] INFO binding to port 0.0.0.0/0.0.0.0:32181 (org.apache.zookeeper.server.NIOServerCnxnFactory)
Note that the message shows the ZooKeeper service listening at the port you passed in as ZOOKEEPER_CLIENT_PORT above.

If the service is not running, the log messages should provide details to help you identify the problem. Some common errors include:

Network port already in use. In that case, you’ll see a message indicating that the ZooKeeper service could not bind to the selected port. Simply change to an open port or identify (and stop) the Docker container that has a service using that port.
Insufficient resources. In rare occasions, you may see memory allocation or other low-level failures at startup. This will only happen if you dramatically overload the capacity of your Docker host.
Kafka
Start Kafka.

$ docker run -d \
    --net=host \
    --name=kafka \
    -e KAFKA_ZOOKEEPER_CONNECT=localhost:32181 \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:29092 \
    -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
    confluentinc/cp-kafka:4.0.0
Note

You’ll notice that the KAFKA_ADVERTISED_LISTENERS variable is set to localhost:29092. This will make Kafka accessible from outside the container by advertising it’s location on the Docker host. You also passed in the ZooKeeper port that you used when launching that container a moment ago. Because you are using --net=host, the hostname for the ZooKeeper service can be left at localhost.

Also notice that KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR is set to 1. This is needed when you are running with a single-node cluster. If you have three or more nodes, you do not need to change this from the default.

Check the logs to see the broker has booted up successfully:

$ docker logs kafka
You should see the following at the end of the log output:

....
[2016-07-15 23:31:00,295] INFO [Kafka Server 1], started (kafka.server.KafkaServer)
...
...
[2016-07-15 23:31:00,349] INFO [Controller 1]: New broker startup callback for 1 (kafka.controller.KafkaController)
[2016-07-15 23:31:00,350] INFO [Controller-1-to-broker-1-send-thread], Starting  (kafka.controller.RequestSendThread)
...
Now you can take this very basic deployment for a test drive. You’ll verify that the broker is functioning normally by creating a topic and producing data to it. You’ll use the client tools directly from another Docker container.

First, you’ll create a topic. You’ll name it foo and keep things simple by just giving it one partition and only one replica. Production environments with more broker nodes would obviously use higher values for both partitions and replicas for scalability and resiliency.

$ docker run \
  --net=host \
  --rm confluentinc/cp-kafka:4.0.0 \
  kafka-topics --create --topic foo --partitions 1 --replication-factor 1 --if-not-exists --zookeeper localhost:32181
You should see the following:

Created topic "foo".
Before moving on, verify that the topic was created successfully:

$ docker run \
  --net=host \
  --rm \
  confluentinc/cp-kafka:4.0.0 \
  kafka-topics --describe --topic foo --zookeeper localhost:32181
You should see the following:

Topic:foo   PartitionCount:1    ReplicationFactor:1 Configs:
Topic: foo  Partition: 0    Leader: 1001    Replicas: 1001  Isr: 1001
Next, you’ll publish some data to your new topic:

$ docker run \
  --net=host \
  --rm \
  confluentinc/cp-kafka:4.0.0 \
  bash -c "seq 42 | kafka-console-producer --request-required-acks 1 --broker-list localhost:29092 --topic foo && echo 'Produced 42 messages.'"
This command will use the built-in Kafka Console Producer to produce 42 simple messages to the topic. After running the command, you should see the following:

Produced 42 messages.
To complete the story, you can read back the message using the built-in Console consumer:

$ docker run \
  --net=host \
  --rm \
  confluentinc/cp-kafka:4.0.0 \
  kafka-console-consumer --bootstrap-server localhost:29092 --topic foo --from-beginning --max-messages 42
If everything is working as expected, each of the original messages you produced should be written back out:

1
....
42
Processed a total of 42 messages
Schema Registry
Now that you have Kafka and ZooKeeper up and running, you can deploy some of the other components included in Confluent Platform. You’ll start by using the Schema Registry to create a new schema and send some Avro data to a Kafka topic. Although you would normally do this from one of your applications, you’ll use a utility provided with Schema Registry to send the data without having to write any code.

First, start the Schema Registry container:

$ docker run -d \
  --net=host \
  --name=schema-registry \
  -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=localhost:32181 \
  -e SCHEMA_REGISTRY_HOST_NAME=localhost \
  -e SCHEMA_REGISTRY_LISTENERS=http://localhost:8081 \
  confluentinc/cp-schema-registry:4.0.0
As you did before, you can check that it started correctly by viewing the logs.

$ docker logs schema-registry
For the next step, you’ll publish data to a new topic that will leverage the Schema Registry. For the sake of simplicity, you’ll launch a second Schema Registry container in interactive mode, and then execute the kafka-avro-console-producer utility from there.

$ docker run -it --net=host --rm confluentinc/cp-schema-registry:4.0.0 bash
Direct the utility at the local Kafka cluster, tell it to write to the topic bar, read each line of input as an Avro message, validate the schema against the Schema Registry at the specified URL, and finally indicate the format of the data.

# /usr/bin/kafka-avro-console-producer \
  --broker-list localhost:29092 --topic bar \
  --property value.schema='{"type":"record","name":"myrecord","fields":[{"name":"f1","type":"string"}]}'
Once started, the process will wait for you to enter messages, one per line, and will send them immediately when you hit the Enter key. Try entering a few messages:

{"f1": "value1"}
{"f1": "value2"}
{"f1": "value3"}
Note

If you hit Enter with an empty line, it will be interpreted as a null value and cause an error. You can simply start the console producer again to continue sending messages.

When you’re done, use Ctrl+C or Ctrl+D to stop the producer client. You can then type exit to leave the container altogether. Now that you’ve written avro data to Kafka, you should check that the data was actually produced as expected to consume it. Although the Schema Registry also ships with a built-in console consumer utility, you’ll instead demonstrate how to read it from outside the container on your local machine via the REST Proxy. The REST Proxy depends on the Schema Registry when producing/consuming avro data, so you’ll need to pass in the details for the detached Schema Registry container you launched above.

REST Proxy
This section describes how to deploy the REST Proxy container and then consume data from the Confluent REST Proxy service.

First, start up the REST Proxy:

$ docker run -d \
  --net=host \
  --name=kafka-rest \
  -e KAFKA_REST_ZOOKEEPER_CONNECT=localhost:32181 \
  -e KAFKA_REST_LISTENERS=http://localhost:8082 \
  -e KAFKA_REST_SCHEMA_REGISTRY_URL=http://localhost:8081 \
  -e KAFKA_REST_HOST_NAME=localhost \
  confluentinc/cp-kafka-rest:4.0.0
For the next two steps, you’re going to use CURL commands to talk to the REST Proxy. Your deployment steps thus far have ensured that both the REST Proxy container and the Schema Registry container are accessible directly through network ports on your local host. The REST Proxy service is listening at http://localhost:8082 As above, you’ll launch a new Docker container from which to execute your commands:

$ docker run -it --net=host --rm confluentinc/cp-schema-registry:4.0.0 bash
The first step in consuming data via the REST Proxy is to create a consumer instance.

# curl -X POST -H "Content-Type: application/vnd.kafka.v1+json" \
  --data '{"name": "my_consumer_instance", "format": "avro", "auto.offset.reset": "smallest"}' \
  http://localhost:8082/consumers/my_avro_consumer
You should see the following:

{"instance_id":"my_consumer_instance","base_uri":"http://localhost:8082/consumers/my_avro_consumer/instances/my_consumer_instance"}
Your next curl command will retrieve data from a topic in your cluster (bar in this case). The messages will be decoded, translated to JSON, and included in the response. The schema used for deserialization is retrieved automatically from the Schema Registry service, which you told the REST Proxy how to find by setting the KAFKA_REST_SCHEMA_REGISTRY_URL variable on startup.

# curl -X GET -H "Accept: application/vnd.kafka.avro.v1+json" \
  http://localhost:8082/consumers/my_avro_consumer/instances/my_consumer_instance/topics/bar
You should see the following:

[{"key":null,"value":{"f1":"value1"},"partition":0,"offset":0},{"key":null,"value":{"f1":"value2"},"partition":0,"offset":1},{"key":null,"value":{"f1":"value3"},"partition":0,"offset":2}]
Confluent Control Center
The Control Center application provides enterprise-grade capabilities for monitoring and managing your Confluent deployment. Control Center is part of the Confluent Enterprise offering; a trial license will support the image for the first 30 days after your deployment.

Stream Monitoring
This portion of the quick start provides an overview of how to use Confluent Control Center with console producers and consumers to monitor consumption and latency.

You’ll launch the Confluent Control Center image the same as you’ve done for earlier containers, connecting to the ZooKeeper and Kafka containers that are already running. This is also a good opportunity to illustrate mounted volumes, so you’ll first create a directory on the Docker Machine host for Control Center data.

$ docker-machine ssh confluent

docker@confluent:~$ mkdir -p /tmp/control-center/data
docker@confluent:~$ exit
Now you start Control Center, binding its data directory to the directory you just created and its HTTP interface to port 9021.

$ docker run -d \
  --name=control-center \
  --net=host \
  --ulimit nofile=16384:16384 \
  -p 9021:9021 \
  -v /tmp/control-center/data:/var/lib/confluent-control-center \
  -e CONTROL_CENTER_ZOOKEEPER_CONNECT=localhost:32181 \
  -e CONTROL_CENTER_BOOTSTRAP_SERVERS=localhost:29092 \
  -e CONTROL_CENTER_REPLICATION_FACTOR=1 \
  -e CONTROL_CENTER_MONITORING_INTERCEPTOR_TOPIC_PARTITIONS=1 \
  -e CONTROL_CENTER_INTERNAL_TOPICS_PARTITIONS=1 \
  -e CONTROL_CENTER_STREAMS_NUM_STREAM_THREADS=2 \
  -e CONTROL_CENTER_CONNECT_CLUSTER=http://localhost:28082 \
  confluentinc/cp-enterprise-control-center:4.0.0
You may notice that you have specified a URL for the Kafka Connect cluster that does not yet exist. Not to worry, you’ll work on that in the next section.

Control Center will create the topics it needs in Kafka. Check that it started correctly by searching it’s logs with the following command:

$ docker logs control-center | grep Started
You should see the following:

[2016-08-26 18:47:26,809] INFO Started NetworkTrafficServerConnector@26d96e5{HTTP/1.1}{0.0.0.0:9021} (org.eclipse.jetty.server.NetworkTrafficServerConnector)
[2016-08-26 18:47:26,811] INFO Started @5211ms (org.eclipse.jetty.server.Server)
To see the Control Center UI, open the link http://<ip-of-docker-host>:9021 in your browser. The Docker Host IP is displayed with the command docker-machine ip confluent. If your Docker daemon is running on a remote machine (such as an AWS EC2 instance), you’ll need to allow TCP access to that instance on port 9021. This is done in AWS by adding a “Custom TCP Rule” to the instance’s security group; the rule should all access to port 9021 from any source IP.

Initially, the Stream Monitoring UI will have no data.

../../../_images/c3-quickstart-init.png
Confluent Control Center Initial View

Next, you’ll run the console producer and consumer with monitoring interceptors configured and see the data in Control Center. First you need to create a topic for testing.

$ docker run \
  --net=host \
  --rm confluentinc/cp-kafka:4.0.0 \
  kafka-topics --create --topic c3-test --partitions 1 --replication-factor 1 --if-not-exists --zookeeper localhost:32181
Now use the console producer with the monitoring interceptor enabled to send data

$ while true;
do
  docker run \
    --net=host \
    --rm \
    -e CLASSPATH=/usr/share/java/monitoring-interceptors/monitoring-interceptors-4.0.0.jar \
    confluentinc/cp-kafka-connect:4.0.0 \
    bash -c 'seq 10000 | kafka-console-producer --request-required-acks 1 --broker-list localhost:29092 --topic c3-test --producer-property interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor --producer-property acks=1 && echo "Produced 10000 messages."'
    sleep 10;
done
This command will use the built-in Kafka Console Producer to produce 10000 simple messages on a 10 second interval to the c3-test topic. After running the command, you should see the following:

Produced 10000 messages.
The message will repeat every 10 seconds, as successive iterations of the shell loop are executed. You can terminate the client with a Ctrl+C.

You’ll use the console consumer with the monitoring interceptor enabled to read the data. You’ll want to run this command in a separate terminal window (prepared with the eval $(docker-machine env confluent) as described earlier).

$ OFFSET=0
$ while true;
do
  docker run \
    --net=host \
    --rm \
    -e CLASSPATH=/usr/share/java/monitoring-interceptors/monitoring-interceptors-4.0.0.jar \
    confluentinc/cp-kafka-connect:4.0.0 \
    bash -c 'kafka-console-consumer --consumer-property group.id=qs-consumer --consumer-property interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor --bootstrap-server localhost:29092 --topic c3-test --offset '$OFFSET' --partition 0 --max-messages=1000'
  sleep 1;
  let OFFSET=OFFSET+1000
done
If everything is working as expected, each of the original messages you produced should be written back out:

1
....
1000
Processed a total of 1000 messages
