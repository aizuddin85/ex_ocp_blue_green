#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage:"
    echo "  $0 GUID REPO CLUSTER"
    echo "  Example: $0 https://github.com/aizuddin85/advdev-blue-green.git#master jenkins"
    exit 1
fi

NAMESPACE=$2
REPO=$1


echo "Ensure running in correct namespace: jenkins..."
oc project ${NAMESPACE}

if [ $? != 0 ]; then
oc new-project ${NAMESPACE}
fi

oc new-app --template=jenkins-persistent --param-file=./setup/params/jenkins.params -n ${NAMESPACE}

oc new-build  -D $'FROM docker.io/openshift/jenkins-agent-maven-35-centos7:v3.11\n
      USER root\nRUN yum -y install skopeo && yum clean all\n
      USER 1001' --name=jenkins-slave-appdev -n ${NAMESPACE}

oc new-build ${REPO} --name=mlbparks-pipeline --context-dir=./MLBParks  -n ${NAMESPACE}
oc new-build ${REPO} --name=nationalparks-pipeline --context-dir=./Nationalparks ${NAMESPACE}
oc new-build ${REPO} --name=parksmap-pipeline --context-dir=./ParksMap ${NAMESPACE}
