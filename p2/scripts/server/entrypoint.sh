#!/bin/bash

curl -sfL https://get.k3s.io | sh -

sudo ln -sf /usr/local/bin/kubectl /usr/bin/kubectl

kubectl create deployment app1 --image=nginx --namespace=default
kubectl expose deployment app1 --type=ClusterIP --port=80 --target-port=80 --namespace=default

kubectl create deployment app2 --image=httpd --replicas=3 --namespace=default
kubectl expose deployment app2 --type=ClusterIP --port=80 --target-port=80 --namespace=default

kubectl create deployment app3 --image=nginx --namespace=default
kubectl expose deployment app3 --type=ClusterIP --port=80 --target-port=80 --namespace=default

kubectl apply -f /vagrant_data/ingress.yaml
