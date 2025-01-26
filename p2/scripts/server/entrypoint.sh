#!/bin/bash

sudo mkdir -p /home/vagrant/.ssh

sudo ssh-keygen -t rsa -f /home/vagrant/.ssh/iot_42 -q -N ""

sudo cp /home/vagrant/.ssh/iot_42 /vagrant_data/iot_42
sudo cp /home/vagrant/.ssh/iot_42.pub /vagrant_data/iot_42.pub

cat /home/vagrant/.ssh/iot_42.pub >> /home/vagrant/.ssh/authorized_keys

sudo chown -R vagrant:vagrant /home/vagrant/.ssh

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -

sudo ln -sf /usr/local/bin/kubectl /usr/bin/kubectl

kubectl version --client

sudo chmod 644 /etc/rancher/k3s/k3s.yaml
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant_data/node-token

echo "K3S Master install finish with success!"

kubectl create deployment app1 --image=nginx --namespace=default
kubectl expose deployment app1 --type=ClusterIP --port=80 --target-port=80 --namespace=default

kubectl create deployment app2 --image=httpd --replicas=3 --namespace=default
kubectl expose deployment app2 --type=ClusterIP --port=80 --target-port=80 --namespace=default

kubectl create deployment app3 --image=nginx --namespace=default
kubectl expose deployment app3 --type=ClusterIP --port=80 --target-port=80 --namespace=default

kubectl apply -f /vagrant_data/ingress.yaml
