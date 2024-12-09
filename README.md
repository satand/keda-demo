# KEDA Showcase

## Infra components
This demo includes the following infra components:

* Custom Metrics Autoscaler Operator
* Red Hat Streams for Apache Kafka (formerly known as Red Hat AMQ Streams Operator)
* Grafana Operator

## Preconditions
Only if in your OCP cluster there isn't an available internal docker registry or if you prefer to use an external docker registry to save the demo built images, you have to create on your machine a docker config file to access to your chosen external registry. It will be necessary to reference this file during the next installation phase

## Installation
After cloning the git repository on your machine and logging in with administrative privileges to your Openshift cluster 

```bash
oc login -u {YOUR_USERNAME} -p {YOUR_PASSWORD} {YOUR_CLUSTER_API_URL}
```
or 
```bash
oc login --token={YOUR_TOKEN} {YOUR_CLUSTER_API_URL}
```

Start the installation with:

```bash
./install.sh
```

**Note**: During the next installation, the process will ask you to answer some questions like:
* install or not necessary operators
* use or not the internal OCP docker registry to save the built images
* select the docker config file for access external docker registry (only in case of you have choosen to not use internal OCP docker registry)
* select the complete repository name for each of built images (only in case of you have choosen to not use internal OCP docker registry)

## Demo time

When the installation process will be completed, you will be able to start the two available Keda demos:

* The first one demo is to show the Keda integration with Apache Kafka and an event based application consuming messageges by a kafka topic. To start this demo you can execute:

```bash
./start-kafka-keda-demo.sh
```

* The second one demo is to show the Keda integration with Prometheus and an  application consuming http request coming from outside by a openshift route and its haproxy. To start this demo you can execute:

```bash
./start-prometheus-keda-demo.sh
```

During both demos you can see the Keda behavior using a preloaded Grafana dashboard. You can see it at the url resulting from execution of:

```bash
oc get route grafana-route -o jsonpath='{"https://"}{.spec.host}{"\n"}' -n keda-demo
```

The predefined Grafana credentials are (username:password): admin:admin

## Uninstall
You can use this command to clean your environment:

```bash
./uninstall.sh
```

**Note**: During the next uninstallation, the process will ask you to answer some questions like:
* uninstall or not the operators

## Useful links
[Red Hat Custom Metrics Autoscaler Operator Openshift Docs](https://docs.openshift.com/container-platform/latest/nodes/cma/nodes-cma-autoscaling-custom.html)

[Keda Docs](https://keda.sh/docs)