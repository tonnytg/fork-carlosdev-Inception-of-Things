#!/bin/bash

set -e 

# SSH
sudo mkdir -p /home/vagrant/.ssh
sudo cp /vagrant_data/id_rsa /home/vagrant/.ssh/id_rsa
sudo cp /vagrant_data/id_rsa.pub /home/vagrant/.ssh/id_rsa.pub

sudo chmod 600 /home/vagrant/.ssh/id_rsa
sudo chmod 644 /home/vagrant/.ssh/id_rsa.pub
sudo chown -R vagrant:vagrant /home/vagrant/.ssh

# K3S
MASTER_IP=192.168.56.110
WORKER_UP=192.168.56.111

ssh -i /home/vagrant/.ssh/id_rsa -o StrictHostKeyChecking=no vagrant@$MASTER_IP "echo 'Connection SSH with success!'"

TOKEN=$(ssh -i /home/vagrant/.ssh/id_rsa -o StrictHostKeyChecking=no vagrant@$MASTER_IP "sudo cat /var/lib/rancher/k3s/server/node-token")
echo "$TOKEN" > /vagrant_data/node-token-worker

curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$TOKEN INSTALL_K3S_EXEC="--node-ip=$WORKER_IP" sh -
sudo ln -sf /usr/local/bin/kubectl /usr/bin/kubectl

sudo mkdir -p /home/vagrant/.kube
sudo cp /vagrant_data/k3s.yaml /home/vagrant/.kube/config
sudo chmod 600 /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube

sudo sed -i 's/127.0.0.1/192.168.56.110/g' /home/vagrant/.kube/config

KUBECONFIG=/home/vagrant/.kube/config

echo 'export KUBECONFIG=/home/vagrant/.kube/config' >> ~/.bashrc
source ~/.bashrc
kubectl get nodes || echo "Error to access cluster!"

echo "✅ K3S Worker connected Master with success!"