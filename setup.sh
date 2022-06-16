#!/bin/bash

# sudo sysctl fs.inotify.max_user_instances=512

# Delete existing if any
kind delete cluster --name  kind

# Create cluster prepared for an ingress controller
kind create cluster --config ./cluster.yaml
kubectl config current-context # should print kind-kind
# kubectl create ns maquette
# kubectl apply -f namespace.yml

# 6.2.5 installed
helm install redis dandydev/redis-ha -f redis-values.yaml \
     --set sentinel.livenessProbe.periodSeconds=5 \
     --set sentinel.livenessProbe.timeoutSeconds=5 \
     --set redis.livenessProbe.periodSeconds=5 \
     --set redis.livenessProbe.timeoutSeconds=5 
# helm install redis -n maquette dandydev/redis-ha -f redis-values.yaml


# perhaps kubectl wait redis ?

# Install ingres-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml


# Build application image
docker build -t shoutbox:latest ./shoutbox

# Load image into cluster
kind load docker-image shoutbox:latest

# Wait for ingress-nginx to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Deploy Kubernetes resources
# kubectl delete -f deployment.yaml
kubectl apply -f deployment.yaml

kubectl get pods # -n maquette
kubectl get pods -A # show coredns
