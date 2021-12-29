# vagrant-kubernetes
this is to spin up three or more virtual machines and install kubernetes inside


## system requirements
This thing needs 8gig 2cpu cores per machine totalling in 24gig for 3 vms

## usage
First you need to up the master because it will generate the join command for nodes (slaves)

```
vagrant up k8s-master
```

Then

```
vagrant up
```

## moar machines
You can change the 'N' in Vagrantfile to however many slaves you want. If you wish you can even boot up virtual machines on multiple bare-metal nodes as long as they live in the same LAN.

## settings and current state
Right now ips and other values are hardcoded, gonna change thet sometime in the future but at the moment setup is the following:

```
static ip addresses for vms:

k8s-master 192.168.1.170

nodes 192.168.1.(170+i)

/etc/hosts have three nodes - master and 2 slaves

master.sh is applied to k8s-master

node.sh is applied to nodes 

there are dead playbooks for ansible there too but they are in need some love 

bash does the job so far for both Windows10+virtualbox and centos7+kvm/libvirt so far, I might delete the playbooks later altogether and just keep bash since windows can't ansible
```