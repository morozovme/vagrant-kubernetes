#!/bin/bash

set -e

kubectl get nodes
kubectl get pods --all-namespaces
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
kubectl create namespace cattle-system
chmod +x cert-manager.sh
./cert-manager.sh
kubectl get pods --namespace cert-manager
helm install rancher rancher-latest/rancher   --namespace cattle-system   --set hostname=rancher.k8s-mater.home
kubectl get pods --all-namespaces
kubectl get svc --all-namespaces

# kubectl edit svc rancher -n cattle-system <--- change ClusterIP to LoadBalancer so the metallb gives and IP address

kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{"\n"}}'

