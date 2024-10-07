#!/bin/bash

sudo mkdir -p /home/vagrant/.ssh

sudo ssh-keygen -t rsa -f /home/vagrant/.ssh/iot_42 -q -N ""

sudo cp /home/vagrant/.ssh/iot_42 /vagrant_data/iot_42
sudo cp /home/vagrant/.ssh/iot_42.pub /vagrant_data/iot_42.pub

cat /home/vagrant/.ssh/iot_42.pub >> /home/vagrant/.ssh/authorized_keys
sudo chown -R vagrant:vagrant /home/vagrant/.ssh

curl -sfL https://get.k3s.io | sh -
sudo ln -sf /usr/local/bin/kubectl /usr/bin/kubectl
kubectl version --client

echo "K3S Master instalado com sucesso!"