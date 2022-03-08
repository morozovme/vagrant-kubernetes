!#/bin/bash 

set -e 

sudo docker run --rm -it   -p 8080:8080   -e DEBUG=1   -e STORAGE=local   -e STORAGE_LOCAL_ROOTDIR=/charts   -v $(pwd)/charts:/charts   ghcr.io/helm/chartmuseum:v0.14.0
