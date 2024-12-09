#!/bin/bash

echo 
echo \####################
echo \## Current Status \##
echo \####################
echo 

oc get pod -n openshift-keda
oc get pod -n openshift-grafana
oc get pod -n amq-streams
oc get pod -n keda-demo
oc get scaledobject -n keda-demo
oc get hpa -n keda-demo -o custom-columns=\
NAME:.metadata.name,\
SCALE_TARGET_KIND:.spec.scaleTargetRef.kind,\
SCALE_TARGET_NAME:.spec.scaleTargetRef.name,\
CURRENT_METRIC:.status.currentMetrics[0].external.current.averageValue,\
TARGET_METRIC:.spec.metrics[0].external.target.averageValue,\
DESIRED_REPLICAS:.status.desiredReplicas,\
CURRENT_REPLICAS:.status.currentReplicas,\
CONDITIONS:.status.conditions[*].type,\
CONDITIONS_STATUS:.status.conditions[*].status
#oc get hpa -n keda-demo -o jsonpath='{"NAME"}{"\t"}{"SCALE_TARGET"}{"\t"}{"METRIC"}{"\t"}{"REPLICAS"}{"\t"}{"CONDITIONS"}{"\n"}{range .items[*]}{.metadata.name}{"\t"}{.spec.scaleTargetRef.kind}{"/"}{.spec.scaleTargetRef.name}{"\t"}{.status.currentMetrics[0].external.current.averageValue}{"/"}{.spec.metrics[0].external.target.averageValue}{"\t"}{.status.currentReplicas}{"/"}{.status.desiredReplicas}{"\t"}{range .status.conditions[*]}{.type}={.status},{" "}{end}{"\n"}{end}'