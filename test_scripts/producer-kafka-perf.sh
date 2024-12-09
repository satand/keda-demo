#!/bin/bash

# Parametri di input
NUM_ITERATIONS=${1:-10}         # Numero massimo di iterazioni (predefinito a 10)
NUM_RECORDS=${2:-500}           # Numero di record (predefinito a 500)
THROUGHPUT=${3:-10}             # Throughput (predefinito a 10)
RECORD_SIZE=${4:-100}           # Dimensione dei record (predefinito a 100)
TOPIC_NAME=${5:-test}           # Nome del topic (predefinito a 'test')

# Loop per eseguire il comando NUM_ITERATIONS volte
for i in $(seq 1 $NUM_ITERATIONS); do
    ./bin/kafka-producer-perf-test.sh --topic $TOPIC_NAME \
        --num-records $NUM_RECORDS \
        --throughput $THROUGHPUT \
        --producer-props bootstrap.servers=localhost:9092 key.serializer=org.apache.kafka.common.serialization.StringSerializer value.serializer=org.apache.kafka.common.serialization.StringSerializer \
        --record-size $RECORD_SIZE &
done

wait
