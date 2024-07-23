#!/bin/bash
export PATH=$PATH:$(go env GOPATH)/bin  
kind create cluster --config=kind-argocd.yaml --name argo

sleep 15

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml --context kind-argo

sleep 15

kubectl create namespace argocd --context kind-argo
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --context kind-argo

sleep 15

kubectl apply -f ingress-argocd.yaml --context kind-argo

sleep 15

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" --context kind-argo | base64 -d && echo
argocd login localhost:80  
argocd cluster add kind-argo --insecure --in-cluster

#argocd proj create dev-spring-boot -d https://kubernetes.default.svc,dev-spring-boot -s https://github.com/bartek-babu/demo.git
#argocd proj create prd-spring-boot -d https://kubernetes.default.svc,prd-spring-boot -s https://github.com/bartek-babu/demo.git

kubectl apply -f dev-spring-boot-project.yaml --context kind-argo
kubectl apply -f prd-spring-boot-project.yaml --context kind-argo
kubectl apply -f spring-boot.yaml --context kind-argo   ##### deploy app of apps before app set so it is visible in argo