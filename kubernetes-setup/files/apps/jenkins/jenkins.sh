#!/bin/bash

set -e


kubectl create namespace jenkins
kubectl create -f jenkins.yaml --namespace jenkins
kubectl create -f jenkins-service.yaml --namespace jenkins


