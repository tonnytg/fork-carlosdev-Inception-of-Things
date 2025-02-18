#!/bin/bash

# SSH
sudo mkdir -p /home/vagrant/.ssh
sudo ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -q -N ""
sudo cp /home/vagrant/.ssh/id_rsa /vagrant_data/id_rsa
sudo cp /home/vagrant/.ssh/id_rsa.pub /vagrant_data/id_rsa.pub
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
sudo chown -R vagrant:vagrant /home/vagrant/.ssh

# K3S
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=192.168.56.110 --tls-san 192.168.56.110" sh -
sudo ln -sf /usr/local/bin/kubectl /usr/bin/kubectl
kubectl version --client

# K3S Key
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant_data/node-token
sudo cp -a /etc/rancher/k3s/k3s.yaml /vagrant_data/k3s.yaml

echo "K3S Master install finish with Success!"