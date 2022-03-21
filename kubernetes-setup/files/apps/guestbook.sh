#!/bin/bash

set -e


# apply mongo deployment 
# 
# kubectl apply -f https://k8s.io/examples/application/guestbook/mongo-deployment.yaml

# apply mongo service
# 
# kubectl apply -f https://k8s.io/examples/application/guestbook/mongo-service.yaml

# apply frontend deployment
#
# kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-deployment.yaml

# name: apply frontend svc
# 
# kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-service.yaml

sudo kubectl apply -f https://k8s.io/examples/application/guestbook/redis-leader-deployment.yaml
sudo kubectl apply -f https://k8s.io/examples/application/guestbook/redis-leader-service.yaml
sudo kubectl apply -f https://k8s.io/examples/application/guestbook/redis-follower-deployment.yaml
sudo kubectl apply -f https://k8s.io/examples/application/guestbook/redis-follower-service.yaml
sudo kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-deployment.yaml


#  guestbook frontend service
# 
#  kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-service.yaml
sudo kubectl apply -f vagrant-kubernetes/kubernetes-setup/files/guestbookLB.yaml

#  guestbook frontend service
# 
#  kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-service.yaml
