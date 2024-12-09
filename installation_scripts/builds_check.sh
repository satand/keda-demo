#!/bin/bash

if [ "$#" -eq 0 ]; then
  echo "Error: You have to specify almost once namespace."
  exit 1
fi

namespaces=("$@")

# local variable
all_in_latest_state=true

for namespace in "${namespaces[@]}"; do
  echo "Check the builds in namespace: $namespace"

  # Check if the builds in specified namespace are all in phase "Complete"
  if ! oc get build -n "$namespace" -o json | jq -e 'all(.items[]; .status.phase == "Complete")' > /dev/null; then
    all_in_latest_state=false
    echo "Some builds in namespace $namespace are not in phase Complete."
    
    oc get build -n "$namespace" -o json | jq '.items[] | select(.status.phase != "Complete") | {namespace: .metadata.namespace, name: .metadata.name, status: .status.phase}'
  fi
done

if $all_in_latest_state; then
  echo "All builds in the specified namespaces are in phase Complete."
  exit 0
else
  exit 1
fi
