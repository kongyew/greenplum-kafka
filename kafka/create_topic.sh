$KAFKA_INSTALL_DIR/bin/kafka-topics.sh --create \
    --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 \
    --topic topic_for_gpkafka
