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

