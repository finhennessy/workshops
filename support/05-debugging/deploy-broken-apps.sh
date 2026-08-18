#!/bin/bash
set -euo pipefail

# oc create namespace debug-lab 2>/dev/null || true
USER=$(oc whoami)
oc new-project debug-lab-${USER}
PROJECT=$(oc project -q)
oc apply -f https://raw.githubusercontent.com/finhennessy/workshops/main/support/broken-apps-v3.yaml

echo ""
echo "Waiting for pods to reach their error states..."
ELAPSED=0
until [ $(oc get pods -n ${PROJECT} --no-headers 2>/dev/null | grep -v ContainerCreating | wc -l) -ge 5 ]; do
  sleep 5; ELAPSED=$((ELAPSED+5))
  [ $ELAPSED -ge 120 ] && echo "Timed out waiting for pods" && break
done

echo ""
oc get pods -n ${PROJECT}
