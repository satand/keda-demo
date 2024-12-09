#!/bin/bash

if [ "$#" -eq 0 ]; then
  echo "Error: You have to specify almost once namespace."
  exit 1
fi

namespaces=("$@")

# local variable
all_in_latest_state=true

for namespace in "${namespaces[@]}"; do
  echo "Check the subscriptions.operators.coreos.com in namespace: $namespace"

  # Check if the subscriptions.operators.coreos.com in specified namespace are all in the state "AtLatestKnown"
  if ! oc get subscriptions.operators.coreos.com -n "$namespace" -o json | jq -e 'all(.items[]; .status.state == "AtLatestKnown")' > /dev/null; then
    all_in_latest_state=false
    echo "Some subscriptions.operators.coreos.com in namespace $namespace are not in the state AtLatestKnown."
    
    oc get subscriptions.operators.coreos.com -n "$namespace" -o json | jq '.items[] | select(.status.state != "AtLatestKnown") | {namespace: .metadata.namespace, name: .metadata.name, status: .status.state}'
  fi
done

if $all_in_latest_state; then
  echo "All subscriptions.operators.coreos.com in the specified namespaces are in state AtLatestKnown."
  exit 0
else
  exit 1
fi
