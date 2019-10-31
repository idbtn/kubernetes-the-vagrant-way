# -*- mode: ruby -*-
# vi: set ft=ruby :

# !!! IMPORTANT NOTE !!!
# !!! Requires vbguest and reload plugins!!!
# sudo vagrant plugin install vagrant-vbguest
# sudo vagrant plugin install vagrant-reload

Vagrant.configure("2") do |config|
	config.vm.box = "idbtn/centos-clean"
	config.vm.synced_folder "./shared", "/mnt/shared", owner: "vagrant", group: "vagrant"


        config.vm.define "loadbalancer1.idbtn.net" do |loadbalancer1|
                loadbalancer1.vm.host_name = "loadbalancer1.idbtn.net"
                loadbalancer1.vm.network "private_network", ip: "192.168.11.10"

                loadbalancer1.vm.provider "virtualbox" do |vb|
                        vb.name = "loadbalancer1.idbtn.net"
                        vb.memory = 1024
                        vb.cpus = 1
                        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
                end
                loadbalancer1.vm.provision :shell, :path => "scripts/haproxy_bootstrap.sh"
        end

	config.vm.define "kubernetesmaster1.idbtn.net" do |master1|
		master1.vm.host_name = "kubernetesmaster1.idbtn.net"
		master1.vm.network :private_network, ip: "192.168.11.21"
		
		master1.vm.provider "virtualbox" do |vb|
			vb.name = "kubernetesmaster1.idbtn.net"
			vb.memory = 2048
			vb.cpus = 2
			vb.customize ["modifyvm", :id, "--cpuexecutioncap", "70"]
		end
                master1.vm.provision :shell, :path => "scripts/master1_bootstrap.sh"
#         	master1.vm.provision :reload
	end

        config.vm.define "kubernetesmaster2.idbtn.net" do |master2|
                master2.vm.host_name = "kubernetesmaster2.idbtn.net"
                master2.vm.network :private_network, ip: "192.168.11.22"

                master2.vm.provider "virtualbox" do |vb|
                        vb.name = "kubernetesmaster2.idbtn.net"
                        vb.memory = 2048
                        vb.cpus = 2
                        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "70"]
                end
                master2.vm.provision :shell, :path => "scripts/master2_bootstrap.sh"
#                master2.vm.provision :reload
        end

        config.vm.define "kubernetesmaster3.idbtn.net" do |master3|
                master3.vm.host_name = "kubernetesmaster3.idbtn.net"
                master3.vm.network :private_network, ip: "192.168.11.23"

                master3.vm.provider "virtualbox" do |vb|
                        vb.name = "kubernetesmaster3.idbtn.net"
                        vb.memory = 2048
                        vb.cpus = 2
                        vb.customize ["modifyvm", :id, "--cpuexecutioncap", "70"]
                end
                master3.vm.provision :shell, :path => "scripts/master3_bootstrap.sh"
#                master3.vm.provision :reload
        end

	config.vm.define "kubernetesnode1.idbtn.net" do |node1|
		node1.vm.host_name = "kubernetesnode1.idbtn.net"
		node1.vm.network :private_network, ip: "192.168.11.31"

		node1.vm.provider "virtualbox" do |vb|
			vb.name = "kubernetesnode1.idbtn.net"
			vb.memory = 1024
			vb.cpus = 1
			vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
		end		
                node1.vm.provision :shell, :path => "scripts/node_bootstrap.sh"
#		node1.vm.provision :reload
		
	end

	config.vm.define "kubernetesnode2.idbtn.net" do |node2|
		node2.vm.host_name = "kubernetesnode2.idbtn.net"
		node2.vm.network :private_network, ip: "192.168.11.32"

		node2.vm.provider "virtualbox" do |vb|
			vb.name = "kubernetesnode2.idbtn.net"
			vb.memory = 1024
			vb.cpus = 1
			vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
		end
                node2.vm.provision :shell, :path => "scripts/node_bootstrap.sh"
#		node2.vm.provision :reload

	end

	config.vm.define "kubernetesnode3.idbtn.net" do |node3|
		node3.vm.host_name = "kubernetesnode3.idbtn.net"
		node3.vm.network :private_network, ip: "192.168.11.33"

		node3.vm.provider "virtualbox" do |vb|
			vb.name = "kubernetesnode3.idbtn.net"
			vb.memory = 1024
			vb.cpus = 1
			vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
		end
                node3.vm.provision :shell, :path => "scripts/node_bootstrap.sh"
#		node3.vm.provision :reload
	end
end
