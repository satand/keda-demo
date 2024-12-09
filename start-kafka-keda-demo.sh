#!/bin/bash

######################################################################
# Copy some test scripts for production phase into the kafka brokers #
######################################################################

oc rsync test_scripts kafka-cluster-kafka-0:/tmp -n keda-demo &
oc rsync test_scripts kafka-cluster-kafka-1:/tmp -n keda-demo &
oc rsync test_scripts kafka-cluster-kafka-2:/tmp -n keda-demo &

wait

#########################
# Start producers kafka #
#########################

oc exec kafka-cluster-kafka-0 -n keda-demo -- /tmp/test_scripts/producer-kafka-perf.sh 10 100 2 100 &
oc exec kafka-cluster-kafka-1 -n keda-demo -- /tmp/test_scripts/producer-kafka-perf.sh 10 100 2 100 &
oc exec kafka-cluster-kafka-2 -n keda-demo -- /tmp/test_scripts/producer-kafka-perf.sh 10 100 2 100 &

wait

watch oc exec kafka-cluster-kafka-0 -n keda-demo -- /opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group kafka-consumer-test --describe

# To reset consumer offset
# oc exec kafka-cluster-kafka-0 -n keda-demo -- /opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group kafka-consumer-test --reset-offsets --to-earliest --topic test --execute
# oc exec kafka-cluster-kafka-0 -n keda-demo -- /opt/kafka/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group kafka-consumer-test --reset-offsets --to-latest --topic test --execute