#!/bin/bash

set -e

# SSH Permissions
sudo mkdir -p /home/vagrant/.ssh
sudo ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -q -N ""
sudo cp /home/vagrant/.ssh/id_rsa /vagrant_data/id_rsa
sudo cp /home/vagrant/.ssh/id_rsa.pub /vagrant_data/id_rsa.pub
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
sudo chown -R vagrant:vagrant /home/vagrant/.ssh

sudo apt-get update -y
sudo apt-get install -y curl apt-transport-https ca-certificates

sudo systemctl stop ufw
sudo systemctl disable ufw

PRIVATE_IP="192.168.56.110"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=${PRIVATE_IP} --bind-address=${PRIVATE_IP} --advertise-address=${PRIVATE_IP} --write-kubeconfig-mode=644" sh - && sleep 10
sudo ln -sf /usr/local/bin/kubectl /usr/bin/kubectl

sudo cp /etc/rancher/k3s/k3s.yaml /vagrant_data/k3s.yaml
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

echo "✅ K3S Master success"

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version || { echo "❌ Error to install"; exit 1; }

echo "✅ Helm installed"

echo "📦 Install apps..."
kubectl apply -f /vagrant_data/app-one.yaml
kubectl apply -f /vagrant_data/app-two.yaml
kubectl apply -f /vagrant_data/app-three.yaml
kubectl apply -f /vagrant_data/ingress.yaml

echo "✅ Success!"
