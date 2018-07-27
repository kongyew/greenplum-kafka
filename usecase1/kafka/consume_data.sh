#!/bin/bash
kafka-console-consumer \
    --bootstrap-server kafka:9092 --topic topic_for_gpkafka \
    --from-beginning
