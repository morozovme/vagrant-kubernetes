# create local store presistent volume example
mkdir -p /home/vagrant/pv1
sudo chmod 777 /home/vagrant/pv1
sudo kubectl create -f vagrant-kubernetes/kubernetes-setup/files/persistance/storageclass.yaml
sudo kubectl create -f vagrant-kubernetes/kubernetes-setup/files/persistance/persistentvolume.yaml