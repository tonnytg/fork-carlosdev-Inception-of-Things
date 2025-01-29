#!/bin/bash

sudo mkdir -p /home/vagrant/.ssh

sudo ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -q -N ""

sudo cp /home/vagrant/.ssh/id_rsa /vagrant_data/id_rsa
sudo cp /home/vagrant/.ssh/id_rsa.pub /vagrant_data/id_rsa.pub

cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys

sudo chown -R vagrant:vagrant /home/vagrant/.ssh

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=192.168.56.110 --tls-san 192.168.56.110" sh -

sudo ln -sf /usr/local/bin/kubectl /usr/bin/kubectl

sudo cp /etc/rancher/k3s/k3s.yaml /vagrant_data/k3s.yaml
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

sudo ufw disable

echo "K3S Master install finish with Success!"

echo "Install Apps"

kubectl apply -f /vagrant_data/app-one.yaml
kubectl apply -f /vagrant_data/app-two.yaml
kubectl apply -f /vagrant_data/app-three.yaml
kubectl apply -f /vagrant_data/ingress.yaml

echo "Finish Install Apps"
