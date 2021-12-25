#!/bin/bash

set -e

NODEIP=$1

#run this dude with sudo

sudo ip route del default via 192.168.121.1
#sudo ip route del default via 10.0.2.2
sudo ip route add default via 192.168.1.1


#sudo echo "UseRoutes=false" >> /run/systemd/network/10-netplan-eth0.network
sudo echo "192.168.1.170 k8s-master.home" >> /etc/hosts
sudo echo "192.168.1.171 node-1.home" >> /etc/hosts
sudo echo "192.168.1.172 node-2.home" >> /etc/hosts
sudo echo " Beginning the circus "



#sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common containerd.io docker-ce docker-cli
#sudo usermod -a -G docker vagrant
#sudo sed -i '/swap/d' /etc/fstab
#sudo swapoff -a 
#wget -qO - https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#
##sudo add-apt-repository https://apt.kubernetes.io/ <??> deb  kubernetes-xenial main kubernetes.list
#sudo apt-get install -y kubelet kubeadm kubectl sshpass
#sudo echo "KUBELET_EXTRA_ARGS=--node-ip=$NODEIP" >> /usr/bin/kubelet
#
#sudo systemctl reload kubelet
#
##scp? scp root@k8s-master
#sshpass -p 'vagrant' scp vagrant@k8s-master:/tmp/join-command /tmp/join-command
#sudo chmod +x /tmp/join-command.sh && sudo /tmp/join-command.sh     
#



sudo apt update
sudo apt -y install curl apt-transport-https sshpass
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt -y install vim git curl wget kubelet kubeadm kubectl
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
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io docker-ce docker-ce-cli

# Create required directories
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo touch /etc/systemd/system/docker.service.d/http-proxy.conf
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://192.168.1.147:3128"
Environment="HTTPS_PROXY=http://192.168.1.147:3128"
EOF

sudo curl http://192.168.1.147:3128/ca.crt > /usr/share/ca-certificates/docker_registry_proxy.crt
sudo echo "docker_registry_proxy.crt" >> /etc/ca-certificates.conf
sudo update-ca-certificates --fresh

#
#  "registry-mirrors": ["http://192.168.1.147:3128"],
# Create daemon json config file
#
#  if you want to use insecure for https
#  "insecure-registries" : ["gcr.io" , "googleapis.com", "quay.io"],
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

#sudo systemctl enable kubelet

#sudo kubeadm config images pull

ssh-keygen -t rsa -N "" -f id_rsa
sudo sshpass -p 'vagrant' ssh-copy-id -i id_rsa -oStrictHostKeyChecking=no vagrant@k8s-master.home
sudo scp -i id_rsa vagrant@k8s-master.home:/tmp/join-command.sh /tmp/join-command.sh
sudo chmod +x /tmp/join-command.sh && sudo /tmp/join-command.sh 
mkdir -p /home/vagrant/pv1
sudo chmod 777 /home/vagrant/pv1
sudo echo " it has been done. "




