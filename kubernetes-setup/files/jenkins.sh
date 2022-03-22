#!/bin/bash

set -e


kubectl create namespace jenkins
kubectl create -f jenkins.yaml --namespace jenkins



