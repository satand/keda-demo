#!/bin/bash

ask_user() {
    local prompt="$1"
    local choice
    while true; do
        read -p "$prompt" choice
        case $choice in
            [Yy] ) echo "yes"; break;;
            [Nn] ) echo "no"; break;;
            * ) echo "Please, answer 'y' for yes or 'n' per no" >&2;;
        esac
    done
}

ask_user_input() {
    local prompt="$1"
    local default="$2"
    local choice
    while true; do
        read -p "$prompt" choice
        case $choice in
            '' ) echo "$default"; break;;
            * ) echo "$choice"; break;;
        esac
    done
}

INSTALL_OPERATORS=$(ask_user "Do you want to install the operators? (y/n): ")

if [[ "$INSTALL_OPERATORS" == "yes" ]]; then
    echo 
    echo \#######################
    echo \## Install Operators \##
    echo \#######################
    echo 

    oc apply -k operators

    # Waiting the end of operator installations
    ./installation_scripts/continuous_check.sh "./installation_scripts/operators_check.sh openshift-keda openshift-grafana amq-streams"
fi

echo 
echo \#########################
echo \## Create demo project \##
echo \#########################
echo 

oc apply -k project

echo 
echo \#############################
echo \## Install Infra instances \##
echo \#############################
echo 

oc apply -k infra

#oc create sa demo-sa -n keda-demo

#oc adm policy add-cluster-role-to-user cluster-monitoring-view -z demo-sa -n keda-demo

#export DEMO_SA_TOKEN_SECRET=$(oc get secret -n keda-demo | grep demo-sa-token | head -n 1 | awk '{ print $1 }')

#cat infra/keda/03.cluster-trigger-authentication-prometheus.yml | envsubst '$DEMO_SA_TOKEN_SECRET' | kubectl apply -f-

#export GRAFANA_SA_TOKEN=$(oc create token grafana-sa -n keda-demo --duration 999h)

#cat infra/grafana/05.grafana-datasource-monitoring.yml | envsubst '$GRAFANA_SA_TOKEN' | kubectl apply -f-

echo 
echo \######################################
echo \## Build the applications for demos \##
echo \######################################
echo 

USE_INTERNAL_REGISTRY=$(ask_user "Do you want to save built images into openshift internal registry? (y/n): ")

if [[ "$USE_INTERNAL_REGISTRY" == "yes" ]]; then

    oc new-build openshift/httpd:2.4-el7~https://github.com/sclorg/httpd-ex \
        --name=httpd-sample \
        -l app.kubernetes.io/part-of=app \
        -n keda-demo

    oc new-build registry.redhat.io/ubi8/openjdk-17~https://github.com/satand/quarkus-kafka-consumer-sample.git \
        --name=kafka-consumer \
        -l app.kubernetes.io/part-of=kafka-app \
        -n keda-demo

    sleep 5

    # Waiting the end of the builds
    ./installation_scripts/continuous_check.sh "./installation_scripts/builds_check.sh keda-demo"

    export HTTP_SAMPLE_IMAGE_TAG=$(oc get is httpd-sample -n keda-demo -o yaml | grep dockerImageRepository | awk '{ print $2 }')
    export KAFKA_CONSUMER_IMAGE_TAG=$(oc get is kafka-consumer -n keda-demo -o yaml | grep dockerImageRepository | awk '{ print $2 }')

else
    DOCKER_CONFIG_FILE=$(ask_user_input "What is the docker config file to use to access the external docker registry (we will use the default \"$HOME/.docker/config.json\" in case of empty answer)?: " "$HOME/.docker/config.json")
    
    oc create secret generic docker-registry \
        --from-file=.dockerconfigjson=$DOCKER_CONFIG_FILE \
        --type=kubernetes.io/dockerconfigjson \
        -n keda-demo

    oc secrets link builder docker-registry -n keda-demo
    oc secrets link default docker-registry -n keda-demo --for=pull

    export HTTP_SAMPLE_IMAGE_TAG=$(ask_user_input "What is the http-sample docker image that you want to use to save the built image into external docker registry (we will use the default \"quay.io/$(whoami)/httpd-sample\" in case of empty answer)?: " "quay.io/$(whoami)/httpd-sample"):$(date +%s)

    oc new-build openshift/httpd:2.4-el7~https://github.com/sclorg/httpd-ex \
        --to-docker=true \
        --to=$HTTP_SAMPLE_IMAGE_TAG \
        --push-secret='docker-registry' \
        --name=httpd-sample \
        -l app.kubernetes.io/part-of=app \
        -n keda-demo

    export KAFKA_CONSUMER_IMAGE_TAG=$(ask_user_input "What is the kafka-sample docker image that you want to use to save the built image into external docker registry (we will use the default \"quay.io/$(whoami)/kafka-consumer\" in case of empty answer)?: " "quay.io/$(whoami)/kafka-consumer"):$(date +%s)

    oc new-build registry.redhat.io/ubi8/openjdk-17~https://github.com/satand/quarkus-kafka-consumer-sample.git \
        --to-docker=true \
        --to=$KAFKA_CONSUMER_IMAGE_TAG \
        --push-secret='docker-registry' \
        --name=kafka-consumer \
        -l app.kubernetes.io/part-of=kafka-app \
        -n keda-demo

    sleep 5

    # Waiting the end of the builds
    ./installation_scripts/continuous_check.sh "./installation_scripts/builds_check.sh keda-demo"
fi

echo 
echo \#######################################
echo \## Deploy the applications for demos \##
echo \#######################################
echo 

oc kustomize services | envsubst '$HTTP_SAMPLE_IMAGE_TAG $KAFKA_CONSUMER_IMAGE_TAG' | oc apply -f-

echo 
echo \############################
echo \## Installation completed \##
echo \############################
echo

sleep 5

./status.sh