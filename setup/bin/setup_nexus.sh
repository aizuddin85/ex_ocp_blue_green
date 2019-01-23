#!/bin/bash
# Setup Nexus Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

NAMESPACE=$1

oc project $NAMESPACE

if [ $? != 0 ]; then
oc new-project ${NAMESPACE}
fi

oc process -f ./setup/templates/nexus3.yaml --param-file=./setup/params/nexus.params | oc create -f - -n ${NAMESPACE}


