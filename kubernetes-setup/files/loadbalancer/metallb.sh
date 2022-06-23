
sudo kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml
sudo kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml
sudo kubectl apply -f vagrant-kubernetes/kubernetes-setup/files/loadbalancer/mllbconfig.yaml
sudo kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"


#sudo kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/metallb.yaml
#kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
#sudo kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/namespace.yaml
#    command: kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/namespace.yaml
#    command: kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
#    command: kubectl apply -f /home/vagrant/mllbconfig.yaml
#    command: kubectl apply -f https://raw.githubusercontent.com/mvallim/kubernetes-under-the-hood/master/services/kube-service-load-balancer.yaml