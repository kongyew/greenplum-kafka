#!/bin/bash
kafka-topics --create \
    --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 \
    --topic topic_for_gpkafka
