#!/bin/bash


set -e
# istio installation and deployment of an app through it
sudo helm repo add istio https://istio-release.storage.googleapis.com/charts
sudo helm repo update
sudo kubectl create namespace istio-system
sudo helm install istio-base istio/base -n istio-system
sudo helm install istiod istio/istiod -n istio-system --wait
sudo kubectl create namespace istio-ingress
sudo kubectl label namespace istio-ingress istio-injection=enabled
sudo helm install istio-ingress istio/gateway -n istio-ingress --wait
sudo helm status istiod -n istio-system
sudo curl -L https://istio.io/downloadIstio | sh -
sudo cd istio-1.12.1
sudo export PATH=$PWD/bin:$PATH
sudo istioctl install --set profile=demo -y
sudo kubectl label namespace default istio-injection=enabled
sudo kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
sudo kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"
sudo kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
sudo istioctl analyze
sudo kubectl get svc istio-ingressgateway -n istio-system