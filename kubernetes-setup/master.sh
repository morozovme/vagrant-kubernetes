#!/bin/bash

set -e

MASTERIP=$1
DOCKERCACHE=$2
APTCACHE=$3
CIDR=$4
KUBEVERSION=$5
MASTERHOSTNAME=$6

export MASTERHOSTNAME=$6
export DOCKERCACHE=$2

# delete vagrant auto-configured default gateway
# to-do: add if default route == 192.168.121.1
sudo ip route del default via 192.168.121.1
# to-do: add if default route == 10.0.2.2
#sudo ip route del default via 10.0.2.2

# add real LAN gateway as default
sudo ip route add default via 192.168.1.1

# to-do: configure netplan for persistance
#sudo echo "UseRoutes=false" >> /run/systemd/network/10-netplan-eth0.network

# to-do: substitute with variables from config.rb, add for each slave loop
sudo echo "$MASTERIP $MASTERHOSTNAME" >> /etc/hosts

# to-do: use credentials from config.rb




# use local LAN apt cache server to save traffic
# if APTCACHE != '' :
if [ -z "$APTCACHE" ]
then
    echo "APTCACHE var is unset, using remote ubuntu mirrors"
else 
    sudo echo 'Acquire::HTTP::Proxy "http://'$APTCACHE'";' >> /etc/apt/apt.conf.d/01proxy
    sudo echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy
fi

sudo apt update
sudo apt -y install vim git curl wget
curl -k -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update



sudo apt-get install -qy kubelet=$KUBEVERSION kubectl=$KUBEVERSION kubeadm=$KUBEVERSION

sudo apt-mark hold kubelet kubeadm kubectl

kubectl version --client && kubeadm version

sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl
sudo sysctl --system

git clone https://github.com/morozovme/vagrant-kubernetes.git

# install container runtime
sudo chmod +x /home/vagrant/vagrant-kubernetes/kubernetes-setup/files/ct-runtime/docker.sh
sudo /home/vagrant/vagrant-kubernetes/kubernetes-setup/files/ct-runtime/docker.sh $MASTERHOSTNAME $DOCKERCACHE



sudo lsmod | grep br_netfilter

sudo systemctl enable kubelet

sudo kubeadm config images pull

sudo echo "KUBELET_EXTRA_ARGS=--node-ip=$MASTERIP" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

sudo kubeadm init --apiserver-advertise-address="$MASTERIP" --apiserver-cert-extra-sans="$MASTERIP"  --node-name "$MASTERHOSTNAME" --pod-network-cidr="$CIDR" --control-plane-endpoint="$MASTERHOSTNAME"
sudo kubeadm token create --print-join-command >> /tmp/join-command.sh


sudo mkdir -p /root/.kube
sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
sudo chown $(id -u):$(id -g) /root/.kube/config

kubectl cluster-info


sudo kubectl create -f vagrant-kubernetes/kubernetes-setup/files/cni/flannel.yaml

# create local store presistent volume example
mkdir -p /home/vagrant/pv1
sudo chmod 777 /home/vagrant/pv1
sudo kubectl create -f vagrant-kubernetes/kubernetes-setup/files/persistence/storageclass.yaml
sudo kubectl create -f vagrant-kubernetes/kubernetes-setup/files/persistence/persistentvolume.yaml
#sudo kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/namespace.yaml
sudo kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml

#kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
sudo kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml
#sudo kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/metallb.yaml
sudo kubectl apply -f vagrant-kubernetes/kubernetes-setup/files/loadbalancer/mllbconfig.yaml
sudo kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

# install helm
sudo curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# use nfs default volume storage
sudo apt-get install nfs-kernel-server nfs-common portmap -y
sudo systemctl start nfs-server
sudo mkdir -p /srv/nfs/mydata 
sudo chmod -R 777 /srv/nfs/ # for simple use but not advised
sudo chown -R nobody:nogroup /srv/nfs/
sudo echo "/srv/nfs/mydata  *(rw,sync,no_subtree_check,no_root_squash,insecure)" >> /etc/exports
sudo exportfs -rv
sudo mount -t nfs $MASTERIP:/srv/nfs/mydata /mnt
sudo helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
sudo helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=$MASTERIP \
    --set nfs.path=/srv/nfs/mydata
# change default storageclass
sudo kubectl patch storageclass local-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
sudo kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'



# to do: 


# add engine stack:
# add kubeadm 
# add kubespray
# add k8s the hard way
# add kubernetes production security setup scripts
# add k3s
# add k0s
# add kind
# add containerd
# add cri-o
# add podman
# add runc
# add OpenShift


# add infra stack:
# add infra configuration to config.rb
# run private docker registry
# setup https on docker registry
# optional: configure and run gitea
# optional: pull repos and push them to gitea
# deploy prometheus 
# deploy grafana
# configure monitoring
# add logging
# add alerting
# add Active Directory
# add WSO2
# add gravitee
# add API Umbrella
# add APIman
# add Kong
# add Tyk
# add Swagger
# add Apigility
# add cert-manager with wildcard cert
# add subdomain configuration xxx.domain.com for apps
# add loki
# add graphite
# add thanos
# add envoy
# add istio (+ HA)
# add master node HA
# add kui
# add kuberlogic
# add telepresence
# add Fission
# add ArgoCD
# add jenkins with values
# configure iac pipelines
# deploy app stack
# add vault
# add keystore
# add helmchart museum
# add SonarQube
# add Sentry
# add metallb
# add LinkerD
# add metrics-server
# add Dashboard


# add storage stack:
# add Ceph
# add NFS
# add MiniO
# add OpenEBS
# add Rook
# add GlusterFS
# add Portworx
# add longHorn


# add app stack
# pull app source and helm chart for dummy app from remote
# build and push to private registry
# deploy to kubernetes app along with resources needed for app
# add OIDC 
# add oauth2 
# add JWT
# add kafka 
# add redis 
# add rabbitmq
# add memcached
# add consul
# add mlops
# add kubeflow
# add vitess
# add patroni
# add percona
# add web3