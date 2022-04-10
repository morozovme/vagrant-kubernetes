#!/bin/bash

set -e


# REPLACE "v0.22.0" with the version you wish to deploy
#kubectl apply -f https://github.com/actions-runner-controller/actions-runner-controller/releases/download/v0.22.0/actions-runner-controller.yaml


helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm upgrade --install --namespace actions-runner-system --create-namespace \
             --wait actions-runner-controller actions-runner-controller/actions-runner-controller





