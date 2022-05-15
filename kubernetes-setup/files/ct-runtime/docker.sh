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
if [ -z "$DOCKERCACHE" ]
then
    echo "DOCKERCACHE var is unset, skipping docker images caching"
else 
    sudo touch /etc/systemd/system/docker.service.d/http-proxy.conf
    sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
    [Service]
    Environment="HTTP_PROXY=http://$DOCKERCACHE"
    Environment="HTTPS_PROXY=http://$DOCKERCACHE"
EOF
    sudo curl http://$DOCKERCACHE/ca.crt > /usr/share/ca-certificates/docker_registry_proxy.crt
    sudo echo "docker_registry_proxy.crt" >> /etc/ca-certificates.conf
    sudo update-ca-certificates --fresh
fi


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

sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
 "log-driver": "json-file",
 "insecure-registries" : [ "$MASTERHOSTNAME:5000" ],
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

#
