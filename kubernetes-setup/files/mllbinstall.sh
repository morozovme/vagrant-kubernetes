from https://mvallim.github.io/kubernetes-under-the-hood/documentation/kube-metallb.html

kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/namespace.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/metallb.yaml
kubectl apply -f mllbconfig.yml
kubectl apply -f https://raw.githubusercontent.com/mvallim/kubernetes-under-the-hood/master/services/kube-service-load-balancer.yaml
