#!/bin/bash

set -e

NODEIP=$1

sudo ip route del default via 192.168.121.1
#sudo ip route del default via 10.0.2.2
sudo ip route add default via 192.168.1.1

#sudo echo "UseRoutes=false" >> /run/systemd/network/10-netplan-eth0.network
sudo echo "192.168.1.170 k8s-master.home" >> /etc/hosts
sudo echo "192.168.1.171 node-1.home" >> /etc/hosts
sudo echo "192.168.1.172 node-2.home" >> /etc/hosts

sudo git config --global user.name "morozovme"
sudo git config --global user.email "m.e.morozov1@gmail.com"
git config --global user.name "morozovme"
git config --global user.email "m.e.morozov1@gmail.com"



#cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
#overlay
#br_netfilter
#EOF
#
#sudo modprobe overlay
#sudo modprobe br_netfilter
#
## Setup required sysctl params, these persist across reboots.
#cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
#net.bridge.bridge-nf-call-iptables  = 1
#net.ipv4.ip_forward                 = 1
#net.bridge.bridge-nf-call-ip6tables = 1
#EOF
#
## Apply sysctl params without reboot
#
#sudo sysctl --system
#sudo apt-get update -y
#sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common docker.io
#sudo usermod -a -G docker vagrant
#sudo sed -i '/swap/d' /etc/fstab
#sudo echo "swap removed from fstab"
#sudo swapoff -a 
##wget -qO - https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
#echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
##sudo add-apt-repository https://apt.kubernetes.io/ <??> deb  kubernetes-xenial main kubernetes.list
#sudo apt-get update
#sudo apt-get install -y kubelet kubeadm kubectl sshpass
#sudo apt-mark hold kubelet kubeadm kubectl
#sudo echo "KUBELET_EXTRA_ARGS=--node-ip=$NODEIP" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
##sudo echo "KUBELET_EXTRA_ARGS=--node-ip=$NODEIP" >> /etc/default/kubelet
##CG=$(sudo docker info 2>/dev/null | sed -n 's/Cgroup Driver: \(.*\)/\1/p')
##sed -i "s/cgroup-driver=systemd/cgroup-driver=$CG/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
##sudo echo "cgroup-driver=cgroupfs" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
##sudo systemctl daemon-reload
##sudo systemctl restart kubelet
##sudo kubeadm init --apiserver-advertise-address="$NODEIP" --apiserver-cert-extra-sans="192.168.1.170"  --node-name k8s-master --pod-network-cidr=172.16.0.0/16 --cgroup-driver=cgroupfs
##sudo mkdir -p /home/vagrant/.kube
##sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
##sudo chown vagrant:vagrant /home/vagrant/.kube/config
##sudo kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml
##sudo kubeadm token create --print-join-command >> /tmp/join-command.sh
##    local_action: copy content="{{ join_command.stdout_lines[0] }}" dest="./files/join-command"





# script2 
# https://computingforgeeks.com/deploy-kubernetes-cluster-on-ubuntu-with-kubeadm/
#
#

#sudo echo 'Acquire::http { Proxy "http://192.168.1.147:3142"; };' >> /etc/apt/apt.conf.d/01proxy
sudo echo 'Acquire::HTTP::Proxy "http://192.168.1.147:3142";' >> /etc/apt/apt.conf.d/01proxy
sudo echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy
#sudo echo 'Acquire::HTTPS::Proxy "https://192.168.1.147:3142";' >> /etc/apt/apt.conf.d/01proxy
#sudo echo 'Acquire::https { Proxy "http://192.168.1.147:3142"; };' >> /etc/apt/apt.conf.d/01proxy
#export http_proxy=http://192.168.1.147:3142
#sudo rm -f /etc/apt/trusted.gpg


sudo apt update
sudo apt -y install vim git curl wget # apt-transport-https
curl -k -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt -y install kubelet kubeadm kubectl
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




#                                               NOTE: You have to choose one runtime at a time.              !!!!!!!!!!!
#  Docker
# Add repo and Install packages
#sudo apt update
#sudo apt install -y curl software-properties-common #gnupg2 # ca-certificates # apt-transport-https 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] http://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io docker-ce docker-ce-cli
#
## Create required directories
sudo mkdir -p /etc/systemd/system/docker.service.d
## adding my local pull-through cache
sudo touch /etc/systemd/system/docker.service.d/http-proxy.conf
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://192.168.1.147:3128"
Environment="HTTPS_PROXY=http://192.168.1.147:3128"
EOF
sudo curl http://192.168.1.147:3128/ca.crt > /usr/share/ca-certificates/docker_registry_proxy.crt
sudo echo "docker_registry_proxy.crt" >> /etc/ca-certificates.conf
sudo update-ca-certificates --fresh

## Reload systemd
systemctl daemon-reload
#
## Restart dockerd
systemctl restart docker.service

## docker images multi-repo pull through cache example
## Simple (no auth, all cache)
##docker run --rm --name docker_registry_proxy -it \
##       -p 0.0.0.0:3128:3128 -e ENABLE_MANIFEST_CACHE=true \
##       -v $(pwd)/docker_mirror_cache:/docker_mirror_cache \
##       -v $(pwd)/docker_mirror_certs:/ca \
##       rpardini/docker-registry-proxy:0.6.2
##
##
##
##  "registry-mirrors": ["http://192.168.1.147:3128"],
## Create daemon json config file
## Create daemon json config file
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
 "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Start and enable Services
sudo systemctl daemon-reload 
sudo systemctl restart docker
sudo systemctl enable docker
#                             -----------------------------

sudo systemctl show --property=Environment docker
#
##        CRI-o
## Ensure you load modules
#sudo modprobe overlay
#sudo modprobe br_netfilter
#
## Set up required sysctl params
#sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
#net.bridge.bridge-nf-call-ip6tables = 1
#net.bridge.bridge-nf-call-iptables = 1
#net.ipv4.ip_forward = 1
#EOF
#
## Reload sysctl
#sudo sysctl --system
#
## Add Cri-o repo
#sudo su -
#OS="xUbuntu_20.04"
#VERSION=1.22
#echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
#echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
#curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | apt-key add -
#curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | apt-key add -
#
## Install CRI-O
#sudo apt update
#sudo apt install cri-o cri-o-runc
#
## Start and enable Service
#sudo systemctl daemon-reload
#sudo systemctl restart crio
#sudo systemctl enable crio
#
#
#
#
##          ContainerD
#
## Configure persistent loading of modules
#sudo tee /etc/modules-load.d/containerd.conf <<EOF
#overlay
#br_netfilter
#EOF
#
## Load at runtime
#sudo modprobe overlay
#sudo modprobe br_netfilter
#
## Ensure sysctl params are set
#sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
#net.bridge.bridge-nf-call-ip6tables = 1
#net.bridge.bridge-nf-call-iptables = 1
#net.ipv4.ip_forward = 1
#EOF
#
## Reload configs
#sudo sysctl --system
#
## Install required packages
#sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
#
## Add Docker repo
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#
## Install containerd
#sudo apt update
#sudo apt install -y containerd.io
#
## Configure containerd and start service
#sudo su -
#mkdir -p /etc/containerd
#containerd config default  /etc/containerd/config.toml
#
## restart containerd
#sudo systemctl restart containerd
#sudo systemctl enable containerd


sudo lsmod | grep br_netfilter

sudo systemctl enable kubelet

sudo kubeadm config images pull

sudo echo "KUBELET_EXTRA_ARGS=--node-ip=$NODEIP" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

sudo kubeadm init --apiserver-advertise-address="$NODEIP" --apiserver-cert-extra-sans="192.168.1.170"  --node-name k8s-master.home --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint=k8s-master.home
sudo kubeadm token create --print-join-command >> /tmp/join-command.sh


sudo mkdir -p /root/.kube
sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
sudo chown $(id -u):$(id -g) /root/.kube/config

kubectl cluster-info

git clone https://github.com/morozovme/vagrant-kubernetes.git
sudo kubectl create -f vagrant-kubernetes/kubernetes-setup/files/flannel.yaml
mkdir -p /home/vagrant/pv1
sudo chmod 777 /home/vagrant/pv1
sudo kubectl create -f vagrant-kubernetes/kubernetes-setup/files/storageclass.yaml
sudo kubectl create -f vagrant-kubernetes/kubernetes-setup/files/persistentvolume.yaml
#sudo kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/namespace.yaml
sudo kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml

#kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
sudo kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml
#sudo kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/metallb.yaml
sudo kubectl apply -f vagrant-kubernetes/kubernetes-setup/files/mllbconfig.yaml
sudo kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

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
sudo curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash


# to do:  install ansible to ad-hoc provision slaves from inventory file simultaneously 



# to-do : install NFS for volumes 
# https://medium.com/@myte/kubernetes-nfs-and-dynamic-nfs-provisioning-97e2afb8b4a9

#sudo systemctl status nfs-server
#sudo apt install -y nfs-kernel-server nfs-common portmap
#sudo start nfs-server
#mkdir -p /srv/nfs/mydata 
#chmod -R 777 /srv/nfs/mydata # for simple use but not advised


# To-Do: use nfs share for docker registry certs 
#
#  https://www.linuxtechi.com/setup-private-docker-registry-kubernetes/
#


sudo apt-get install nfs-kernel-server nfs-common portmap -y
sudo systemctl start nfs-server
sudo mkdir -p /srv/nfs/mydata 
sudo chmod -R 777 /srv/nfs/ # for simple use but not advised
sudo chown -R nobody:nogroup /srv/nfs/
sudo echo "/srv/nfs/mydata  *(rw,sync,no_subtree_check,no_root_squash,insecure)" >> /etc/exports
sudo exportfs -rv
sudo mount -t nfs 192.168.1.170:/srv/nfs/mydata /mnt
sudo helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
sudo helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=192.168.1.170 \
    --set nfs.path=/srv/nfs/mydata

sudo kubectl patch storageclass local-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
sudo kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'


#  guestbook frontend service
# 
#  kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-service.yaml


# install gitlab to kubernetes

#sudo helm repo add gitlab https://charts.gitlab.io/

#sudo helm install gitlab gitlab/gitlab \
#  --set global.hosts.domain=gitlab.morozovme.com \
#  --set certmanager-issuer.email=m.e.morozov1@gmail.com

#sudo kubectl get ingress -lrelease=gitlab
#sudo echo "------passwd for gitlabci:"
#sudo kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo



