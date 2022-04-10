#!/bin/bash

set -e

# using manifests
kubectl create namespace jenkins
kubectl create -f jenkins.yaml --namespace jenkins
kubectl create -f jenkins-service.yaml --namespace jenkins

# using helm
#kubectl create namespace jenkins
#helm repo add jenkins https://charts.jenkins.io
#helm repo update
#helm install -f values.yaml jenkins/jenkins --generate-name --namespace jenkins
#helm show values jenkins/jenkins