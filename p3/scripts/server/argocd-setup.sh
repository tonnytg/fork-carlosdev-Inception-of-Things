#!/bin/bash

echo "Start Install Argo"

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait ArgoCD
echo "Waiting ArgoCD install..."
kubectl wait --for=condition=available --timeout=400s -n argocd deployments -l app.kubernetes.io/part-of=argocd
echo "Finish ArgoCD Install"

# Disable ArgoCD SSL HTTPS/gRPC
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'

# Restart ArgoCD
kubectl rollout restart deployment argocd-server -n argocd

# Install ArgoCD Cli
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

# Config Localhost DNS
echo "127.0.0.1 argocd.local" | sudo tee -a /etc/hosts

# Config Ingress to Proxy to argocd.local to Service
kubectl apply -f traefik-crd-and-ingress.yaml -n argocd

# Waiting apply new settings
kubectl wait --for=condition=available --timeout=400s -n argocd deployments -l app.kubernetes.io/part-of=argocd

# ArgoCD Password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)

# Config ArgoCD Cli
echo "Config ArgoCD"
while ! argocd login argocd.local --username admin --password ${ARGOCD_PASSWORD} --insecure; 
do 
    echo "Trying connect to ArgoCD Server..."; 
    sleep 2 
done
echo "Login Success"

# Change Password
argocd account update-password --current-password "${ARGOCD_PASSWORD}" --new-password admin@123

# Add Repo
argocd repo add https://github.com/tonnytg/42_inception_of_things_dev_app

# Create App
argocd app create dev-app \
  --repo https://github.com/tonnytg/42_inception_of_things_dev_app.git \
  --path k8s/manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated

# List Apps
argocd app list

echo "Finish"
