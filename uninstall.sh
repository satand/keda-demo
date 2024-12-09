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

UNINSTALL_OPERATORS=$(ask_user "Do you want to uninstall the operators? (y/n): ")

echo 
echo \################################
echo \## Uninstall the applications \##
echo \################################
echo 

oc delete all,secret,route,scaledobject,triggerauthentication --selector app=httpd-sample -n keda-demo

oc delete all,secret,scaledobject,triggerauthentication --selector app=kafka-consumer -n keda-demo

echo 
echo \###############################
echo \## Uninstall Infra instances \##
echo \###############################
echo 

oc delete clustertriggerauthentication --selector app.kubernetes.io/part-of=keda-infra
oc delete all,secret,pvc,kedacontroller --selector app.kubernetes.io/part-of=keda-infra -n openshift-keda
oc delete clusterrolebinding --selector app.kubernetes.io/part-of=keda-infra
oc delete sa --selector app.kubernetes.io/part-of=keda-infra -n openshift-keda

oc delete all,secret,cm,kafka,podmonitor,kafkatopic --selector app.kubernetes.io/part-of=kafka-infra -n keda-demo

oc delete all,secret,grafana,grafanadatasource,grafanafolder,grafanadashboard,route --selector app.kubernetes.io/part-of=grafana-infra -n keda-demo
oc delete clusterrolebinding --selector app.kubernetes.io/part-of=grafana-infra
oc delete sa --selector app.kubernetes.io/part-of=grafana-infra -n keda-demo

echo 
echo \####################
echo \## Delete project \##
echo \####################
echo 

oc delete project keda-demo

if [[ "$UNINSTALL_OPERATORS" == "yes" ]]; then

    echo 
    echo \#########################
    echo \## Uninstall operators \##
    echo \#########################
    echo 

    currentCSV=$(oc get subscriptions.operators.coreos.com openshift-custom-metrics-autoscaler-operator -n openshift-keda -o yaml | grep currentCSV | awk '{ print $2 }')
    oc delete subscriptions.operators.coreos.com openshift-custom-metrics-autoscaler-operator -n openshift-keda
    oc delete clusterserviceversion $currentCSV -n openshift-keda
    oc delete project openshift-keda

    currentCSV=$(oc get subscriptions.operators.coreos.com grafana-operator -n openshift-grafana -o yaml | grep currentCSV | awk '{ print $2 }')
    oc delete subscriptions.operators.coreos.com grafana-operator -n openshift-grafana
    oc delete clusterserviceversion $currentCSV -n openshift-grafana
    oc delete project openshift-grafana

    currentCSV=$(oc get subscriptions.operators.coreos.com amq-streams -n amq-streams -o yaml | grep currentCSV | awk '{ print $2 }')
    oc delete subscriptions.operators.coreos.com amq-streams -n amq-streams
    oc delete clusterserviceversion $currentCSV -n amq-streams
    oc delete project amq-streams
fi

echo 
echo \##############################
echo \## Uninstallation completed \##
echo \##############################
echo 
