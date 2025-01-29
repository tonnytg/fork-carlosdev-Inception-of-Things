#!/bin/bash

set -e

# Atualize os pacotes
sudo apt-get update -y

# Instale dependências para o Docker
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Adicione a chave GPG do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Adicione o repositório do Docker
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu focal stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instale o Docker Engine
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Adicione o usuário vagrant ao grupo docker
sudo usermod -aG docker vagrant

# Instale o K3D
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Instale o Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Crie um cluster K3D
k3d cluster create caalbertCluster

# Download Binary kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Configure kubectl
sudo mkdir -p /home/vagrant/.kube
sudo cp -i /root/.kube/config /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube

# Adicione o repositório do ArgoCD no Helm
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Instale o ArgoCD no cluster
kubectl create namespace argocd
helm install argocd argo/argo-cd --namespace argocd
