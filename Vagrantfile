# -*- mode: ruby -*-
# vi: set ft=ruby :

require './config.rb'


IMAGE_NAME = "generic/ubuntu1804"
N = 2

Vagrant.configure("2") do |config|
    config.ssh.insert_key = 'false'
    config.vm.provider :libvirt do |libvirt|
        libvirt.memory = 8192
        libvirt.cpus = 2
        libvirt.storage :file, :size => '50G'
    end

    config.vm.define "k8s-master" do |master|
        master.vm.box = IMAGE_NAME
        master.vm.network "public_network", bridge: "br0", dev: "br0", type: "bridge", mode: "bridge", ip: MASTERIP
        master.vm.hostname = "k8s-master.home"
        master.vm.provision :shell, :path => "kubernetes-setup/master.sh", :args => MASTERIP

    end
end

Vagrant.configure("2") do |config|
    config.ssh.insert_key = 'false'
    config.vm.provider :libvirt do |v|
        v.memory = 8192
        v.cpus = 2
        v.storage :file, :size => '50G'
    end

    (1..N).each do |i|
        config.vm.define "node-#{i}" do |node|
            node.vm.box = IMAGE_NAME
            node_ip = NODEIP[i]
            node.vm.network "public_network", bridge: "br0", dev: "br0", type: "bridge", mode: "bridge", ip: "#{node_ip}"
            node.vm.hostname = "node-#{i}.home"
            node.vm.provision :shell, :path => "kubernetes-setup/node.sh", :args => "#{node_ip}"

        end
    end
end