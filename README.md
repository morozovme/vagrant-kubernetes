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
Use config.rb to set list of LAN static ip addresses

## problems

Problems there are... 

1) vagrant adds default NIC that it uses to configure and provision VMS. It configures default route to that NIC which is NAT. K8s can't use that so the workaround is to: 
- Add second NIC and assign static IP address to that and add all the vms hostnames and addresses to /etc/hosts
- reconfigure default routes, drop gateway added by vagrant through virtualbox/libvirt and set our LAN default gateway
- (to-do) use netplan to make this permanent so the cluster survives reboot and avoid manually reconfiguring default gateways

2) Virtualbox/libvirt assign different CIDR blocks to default gateways so you have pay attention to that when deleting gw

3) At the moment hashicorp had blocked rus ip addresses so you can't download and install vagrant if you don't have VPN. You might wanna git clone and build vagrant and vagrant-libvirt plugin manually on a clean system (that's what I did)

4) (to-do) firewalld blocks libvirt VM traffic if you build vagrant manually. W/a = systemctl stop firewalld && systemct disable firewalld

5) vagrant boxes aren't downloadable from hashicorp due to ip ban

6) (to-do) Vagrantfile needs adjustment for libvirt/virtualbox vm config atm. Need to add provider detection.