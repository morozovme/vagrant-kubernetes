#!/bin/bash

set -e

#kubectl create namespace minio
helm repo add minio https://charts.min.io/
helm install --namespace minio --set rootUser=rootuser,rootPassword=rootpass123 --generate-name minio/minio  --set resources.requests.memory=2Gi
#--set persistence.size=100Gi
#helm get values my-release > old_values.yaml
#helm upgrade -f old_values.yaml my-release minio/minio
#kubectl annotate namespace default "net.beta.kubernetes.io/network-policy={\"ingress\":{\"isolation\":\"DefaultDeny\"}}"


# kubectl create secret generic my-minio-secret --from-literal=rootUser=foobarbaz --from-literal=rootPassword=foobarbazqux
# helm install --set existingSecret=my-minio-secret minio/minio
# kubectl create secret generic tls-ssl-minio --from-file=path/to/private.key --from-file=path/to/public.crt
# helm install --set tls.enabled=true,tls.certSecret=tls-ssl-minio minio/minio
# kubectl -n minio create secret generic minio-trusted-certs --from-file=public.crt --from-file=keycloak.crt
# kubectl -n minio create secret generic minio-trusted-certs --from-file=keycloak.crt


