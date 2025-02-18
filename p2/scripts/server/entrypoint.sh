#!/bin/bash

# SSH Permissions
sudo mkdir -p /home/vagrant/.ssh
sudo ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -q -N ""
sudo cp /home/vagrant/.ssh/id_rsa /vagrant_data/id_rsa
sudo cp /home/vagrant/.ssh/id_rsa.pub /vagrant_data/id_rsa.pub
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
sudo chown -R vagrant:vagrant /home/vagrant/.ssh

# Update Repolist
sudo apt-get update -y
sudo apt-get install -y curl apt-transport-https ca-certificates

# Install Helm Package Manager for Kubernetes
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version || { echo "Error to install Helm"; exit 1; }

# Disable Firewall for K3S
sudo systemctl stop ufw
sudo systemctl disable ufw

# Set Master
PRIVATE_IP="192.168.56.110"

# Install K3S
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=${PRIVATE_IP} --bind-address=192.168.56.110 --advertise-address=${PRIVATE_IP} --write-kubeconfig-mode=644" sh - && sleep 10
sudo ln -sf /usr/local/bin/kubectl /usr/bin/kubectl
sudo cp /etc/rancher/k3s/k3s.yaml /vagrant_data/k3s.yaml
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

echo "K3S Master install finished with success!"

echo "Install Apps"

kubectl apply -f /vagrant_data/app-one.yaml
kubectl apply -f /vagrant_data/app-two.yaml
kubectl apply -f /vagrant_data/app-three.yaml
kubectl apply -f /vagrant_data/ingress.yaml

echo "Finish apps"
