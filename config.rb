# -*- mode: ruby -*-
# vi: set ft=ruby :
#
### CONFIG PARAMS ###
GITNAME=''
GITEMAIL=''
GITEDITOR='vim'
GITVERSION='2.23.0'
GITHUBUSER=''

MASTERIP='192.168.1.170'
NODEIP = ['192.168.1.171', '192.168.1.172', '192.168.1.173', '192.168.1.174', '192.168.1.175']
CIDR = '10.244.0.0/16'
MASTERHOSTNAME = 'k8s-master'
DOCKERCACHE = '192.168.1.147:3128'
APTCACHE = '192.168.1.147:3142'
KUBEVERSION='1.23.0-00'