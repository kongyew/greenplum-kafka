#!/bin/bash

apt-get update
apt-get install build-essential software-properties-common -y
apt-get install python-dev -y

pip install --upgrade pip

pip install confluent-kafka

# for AvroProducer or AvroConsumer
pip install confluent-kafka[avro]
