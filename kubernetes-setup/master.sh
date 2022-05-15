#!/bin/bash

set -e

MASTERIP=$1
DOCKERCACHE=$2
APTCACHE=$3
CIDR=$4
KUBEVERSION=$5
MASTERHOSTNAME=$6

#export MASTERHOSTNAME=$6

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

# use local LAN apt cache server to save traffic
# if APTCACHE != '' :
if [ -z "$APTCACHE" ]
then
    echo "APTCACHE var is unset, using remote ubuntu mirrors"
else 
    sudo echo 'Acquire::HTTP::Proxy "http://'$APTCACHE'";' >> /etc/apt/apt.conf.d/01proxy
    sudo echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy
fi

#sudo echo 'Acquire::http { Proxy "http://192.168.1.147:3142"; };' >> /etc/apt/apt.conf.d/01proxy

#sudo echo 'Acquire::HTTPS::Proxy "https://192.168.1.147:3142";' >> /etc/apt/apt.conf.d/01proxy
#sudo echo 'Acquire::https { Proxy "http://192.168.1.147:3142"; };' >> /etc/apt/apt.conf.d/01proxy
#export http_proxy=http://192.168.1.147:3142
#sudo rm -f /etc/apt/trusted.gpg




sudo apt update
sudo apt -y install vim git curl wget # apt-transport-https
curl -k -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update

# https://stackoverflow.com/questions/49721708/how-to-install-specific-version-of-kubernetes
#
# curl -s https://packages.cloud.google.com/apt/dists/kubernetes-xenial/main/binary-amd64/Packages | grep Version | awk '{print $2}'

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
sudo /home/vagrant/vagrant-kubernetes/kubernetes-setup/files/ct-runtime/docker.sh



sudo lsmod | grep br_netfilter

sudo systemctl enable kubelet

sudo kubeadm config images pull

sudo echo "KUBELET_EXTRA_ARGS=--node-ip=$MASTERIP" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# to-do: use ip var
# to-do: use CIDR var
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



 



