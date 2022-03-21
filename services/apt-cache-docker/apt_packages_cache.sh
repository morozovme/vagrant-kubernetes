#!/bin/bash 

set -e

sudo docker build -t eg_apt_cacher_ng .
sudo docker run -d -p 3142:3142 --name test_apt_cacher_ng eg_apt_cacher_ng
sudo docker logs -f test_apt_cacher_ng