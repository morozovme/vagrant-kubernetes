#!/bin/bash
set -e

#vagrant is weird on centos8 so this is what has to be done in order to remove a vm

vagrant destroy --force k8s-master
virsh pool-list
virsh vol-list default
#virsh vol-delete --pool default generic-VAGRANTSLASH-ubuntu1804_vagrant_box_image_3.0.32.imgvirsh vol-list default
rm -f /var/lib/libvirt/images/vagrant*
virsh pool-refresh default
virsh vol-list default
vagrant destroy --force
virsh pool-refresh default
virsh vol-list default
#  virsh vol-delete --pool default ubuntu-work_master-vdb.qcow2 /var/lib/libvirt/images/ubuntu-work_master-vdb.qcow2
