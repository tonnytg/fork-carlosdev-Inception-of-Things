#!/bin/bash

# Criando diretório para chaves SSH
sudo mkdir -p /home/vagrant/.ssh

# Gerando chave SSH para comunicação entre nós
sudo ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -q -N ""

# Copiando chaves para compartilhamento
sudo cp /home/vagrant/.ssh/id_rsa /vagrant_data/id_rsa
sudo cp /home/vagrant/.ssh/id_rsa.pub /vagrant_data/id_rsa.pub

# Autorizando chave pública para acesso sem senha
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys

# Ajustando permissões
sudo chown -R vagrant:vagrant /home/vagrant/.ssh

# Atualizando pacotes e instalando dependências
sudo apt-get update -y
sudo apt-get install -y curl apt-transport-https ca-certificates

# Instalando Helm antes do K3s
echo "Instalando Helm..."
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verificando a instalação do Helm
helm version || { echo "Erro ao instalar o Helm"; exit 1; }


# Atualiza e instala dependências
sudo apt update && sudo apt install -y curl

# Desativa o firewall para evitar bloqueios
sudo systemctl stop ufw
sudo systemctl disable ufw

# Defina o IP da rede privada
PRIVATE_IP="192.168.56.110"

# Instala o K3s garantindo que o node use o IP privado
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=${PRIVATE_IP} --bind-address=192.168.56.110 --advertise-address=${PRIVATE_IP} --write-kubeconfig-mode=644" sh - && sleep 10

# Criando link simbólico para facilitar o uso do kubectl
sudo ln -sf /usr/local/bin/kubectl /usr/bin/kubectl

# Salvando o kubeconfig para acesso externo
sudo cp /etc/rancher/k3s/k3s.yaml /vagrant_data/k3s.yaml
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# Finalizando instalação
echo "K3S Master install finished with success!"

echo "Install Apps"

kubectl apply -f /vagrant_data/app-one.yaml
kubectl apply -f /vagrant_data/app-two.yaml
kubectl apply -f /vagrant_data/app-three.yaml
kubectl apply -f /vagrant_data/ingress.yaml

echo "Finish apps"
