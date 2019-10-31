#!/bin/bash

token_path="/mnt/shared/k8s_token"
ca_cert_hash_path="/mnt/shared/k8s_ca_cert_hash"
cert_key_path="/mnt/shared/k8s_cert_key"

# Update /etc/fstab with vagrant entry in order to remount vagrant shared directory after reboot.
sudo su -c 'echo "vagrant /vagrant vboxsf defaults 0 0" >> /etc/fstab'

# Set firewall rules
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=10251/tcp
sudo firewall-cmd --permanent --add-port=10252/tcp
sudo firewall-cmd --permanent --add-port=10255/tcp
sudo firewall-cmd --reload

# Set firewall rules for Flannel.
sudo firewall-cmd --permanent --add-port=8285/udp
sudo firewall-cmd --permanent --add-port=8472/udp
sudo firewall-cmd --reload


# Add all hostnames to /etc/hosts files on each server:
sudo su -c 'echo "192.168.11.10    loadbalancer1.idbtn.net       loadbalancer1
192.168.11.21    kubernetesmaster1.idbtn.net   kubernetesmaster1
192.168.11.22    kubernetesmaster2.idbtn.net   kubernetesmaster2
192.168.11.23    kubernetesmaster3.idbtn.net   kubernetesmaster3
192.168.11.31    kubernetesnode1.idbtn.net     kubernetesnode1
192.168.11.32    kubernetesnode2.idbtn.net     kubernetesnode2
192.168.11.33    kubernetesnode3.idbtn.net     kubernetesnode3" >> /etc/hosts'

# Disable SELinux to allow containers to access the host filesystem.
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Disable swap.
sudo swapoff -a
# Also remove swap entry from /etc/fstab.
sudo su -c "sed -e '/^#/! {/swap/ s/^/#/}' -i /etc/fstab"

# To avoid iptables being bypassed ensure the net.bridge.bridge-nf-call-iptables is set to 1.
sudo su -c 'cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF'

# Apply the new k8s configuration for sysctl.
sudo sysctl --system

# Ensure br_netfilter kernel module is loaded.
sudo modprobe br_netfilter --first-time

# Also ensure the following kernel modules are loaded.
sudo modprobe nf_conntrack_ipv4 --first-time
sudo modprobe ip_vs --first-time
sudo modprobe ip_vs_rr --first-time
sudo modprobe ip_vs_wrr --first-time
sudo modprobe ip_vs_sh --first-time

# Install docker-ce.
# Install package dependencies for docker-ce.
sudo yum install yum-utils device-mapper-persistent-data lvm2 -y
# Add docker-ce repository.
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# Install docker.
sudo yum install docker-ce -y
# Enable docker service.
sudo systemctl enable docker.service
# Start docker service.
sudo systemctl start docker.service

# Add kubernetes repository.
sudo su -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF'

# Check if the repository is available. Use -y to accept the google rpm package gpg key.
sudo yum repolist -y
# Check kubernetes control plane latest version here:  https://storage.googleapis.com/kubernetes-release/release/stable.txt
# Kubelet needs to be at least the same version as API Server version. Search for kubernetes and kubeadm skew policy.
# Install kubelet.
sudo yum -y install kubelet
# Enable kubelet service.
sudo systemctl enable kubelet.service
# Start kubelet service
sudo systemctl start kubelet.service

# Install kubectl.
sudo yum install kubectl -y

# Install kubeadm.
sudo yum install kubeadm -y

# Before initializing the cluster, force a kubeadm reset.
sudo kubeadm reset -f

# Reset iptables.
sudo su -c "iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X"

# Install ipvsadm
sudo yum install ipvsadm -y
# Run ipvsadm --clear in case the cluster was setup to utilize IPVS.
sudo ipvsadm --clear

# Join new control-plane node to existing cluster.
# TODO Get apiserver advertise address from somewhere.
sudo kubeadm join loadbalancer1.idbtn.net:6443 --token $(cat ${token_path}) --discovery-token-ca-cert-hash sha256:$(cat ${ca_cert_hash_path}) --control-plane --certificate-key $(cat ${cert_key_path}) --apiserver-advertise-address "192.168.11.23"

# Enable using the cluster as vagrant.
mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config

sleep 4m

# Check if control-plane static pods are up and ready.
# kubectl -n kube-system get pods

# Apply flannel pod overlay network yaml file.
sudo su - vagrant -c "kubectl apply -f /vagrant/kube-flannel.yaml"

exit 0
