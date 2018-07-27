#!/bin/bash
# kafka-console-producer \
#     --broker-list kafka:9092 \
#     --topic topic_for_gpkafka < sample_data.csv



for x in {1..100}; do cat sample_data.csv; sleep 2; done | kafka-console-producer --broker-list kafka:9092  --topic topic_for_gpkafka
