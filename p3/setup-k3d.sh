#!/bin/bash
set -e

echo "Start Configure VM Base"

sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git

# Docker Engine
sudo apt install -y docker.io
sudo usermod -aG docker vagrant
newgrp docker

# K3D
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# cluster K3D
k3d cluster create caalbertS --servers 1 --agents 2 --port 80:80@loadbalancer --port 443:443@loadbalancer

# kubectl
mkdir -p /home/vagrant/.kube
k3d kubeconfig get caalbertS > /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Finish Base VM
echo "Finish Setup VM Base"

bash /vagrant_data/argocd-setup.sh
