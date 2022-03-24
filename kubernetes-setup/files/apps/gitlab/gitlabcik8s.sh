#!/bin/bash 

set -e


# install gitlab to kubernetes

#sudo helm repo add gitlab https://charts.gitlab.io/

#sudo helm install gitlab gitlab/gitlab \
#  --set global.hosts.domain=gitlab.morozovme.com \
#  --set certmanager-issuer.email=m.e.morozov1@gmail.com

#sudo kubectl get ingress -lrelease=gitlab
#sudo echo "------passwd for gitlabci:"
#sudo kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo