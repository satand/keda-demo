#!/bin/bash

#######################################
# Invoke continuously the httpd route #
#######################################

export URL=$(oc get route httpd-sample -n keda-demo -o yaml | yq '.spec.host')

while true; do curl -I $URL; done