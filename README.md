## Kubernetes The Vagrant Way

The projects objective is to ease the deployment of a highly available kubernetes cluster with 3 Master Nodes and 3 Workers using kubeadm.

Prerequisites:  
VirtualBox  
Vagrant  
Internet connection in order to download the [Base Box](https://app.vagrantup.com/idbtn/boxes/centos-clean) from HashiCorp's Vagrant Cloud.

## Instructions

```bash
git clone git@github.com:IonutDanielButnariu/kubernetes-the-vagrant-way.git ktvw
cd ktvw
vagrant up
```

Wait for scripts to finish. At the end you will have a freshly installed kubernetes cluster.

To start using the cluster, connect to master and run kubernetes commands with:
```
vagrant ssh kubernetesmaster1.idbtn.net
kubectl get nodes
```


