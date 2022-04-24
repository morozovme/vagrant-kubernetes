export FISSION_NAMESPACE="fission"
kubectl create namespace $FISSION_NAMESPACE
kubectl create -k "github.com/fission/fission/crds/v1?ref=v1.15.1"
helm repo add fission-charts https://fission.github.io/fission-charts/
helm repo update
helm install --version v1.15.1 --namespace $FISSION_NAMESPACE fission \
	  --set serviceType=NodePort,routerServiceType=NodePort \
	    fission-charts/fission-all

sleep 20s
curl -Lo fission https://github.com/fission/fission/releases/download/v1.15.1/fission-v1.15.1-linux-amd64 \
	    && chmod +x fission && sudo mv fission /usr/local/bin/
fission env create --name nodejs --image fission/node-env
curl -LO https://raw.githubusercontent.com/fission/examples/main/nodejs/hello.js
fission function create --name hello-js --env nodejs --code hello.js
fission function test --name hello-js
