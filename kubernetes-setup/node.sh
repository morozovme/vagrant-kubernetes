#!/bin/bash

set -e

MASTERIP=$1
NODEIP=$2
DOCKERCACHE=$3
APTCACHE=$4
KUBEVERSION=$5
MASTERHOSTNAME=$6

#run this dude with sudo

sudo ip route del default via 192.168.121.1
#sudo ip route del default via 10.0.2.2
sudo ip route add default via 192.168.1.1


#sudo echo "UseRoutes=false" >> /run/systemd/network/10-netplan-eth0.network
sudo echo "$MASTERIP $MASTERHOSTNAME" >> /etc/hosts
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

if [ -z "$APTCACHE" ]
then
    echo "APTCACHE var is unset, using remote ubuntu mirrors"
else 
    sudo echo 'Acquire::HTTP::Proxy "http://'$APTCACHE'";' >> /etc/apt/apt.conf.d/01proxy
    sudo echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy
fi

sudo apt update
sudo apt -y install curl apt-transport-https sshpass
curl -k -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt -y install vim git curl wget
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

#sudo systemctl enable kubelet

#sudo kubeadm config images pull
sudo apt-get install nfs-common -y
ssh-keygen -t rsa -N "" -f id_rsa
sudo sshpass -p 'vagrant' ssh-copy-id -i id_rsa -oStrictHostKeyChecking=no vagrant@k8s-master.home
sudo scp -i id_rsa vagrant@k8s-master.home:/tmp/join-command.sh /tmp/join-command.sh
sudo chmod +x /tmp/join-command.sh && sudo /tmp/join-command.sh 
mkdir -p /home/vagrant/pv1
sudo chmod 777 /home/vagrant/pv1
sudo echo " it has been done. "




