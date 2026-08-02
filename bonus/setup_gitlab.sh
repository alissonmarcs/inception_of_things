#!/bin/bash

set -ex

k3d cluster create -p '10.0.2.15:443:443@loadbalancer' -p '10.0.2.15:80:80@loadbalancer' -p '10.0.2.15:20:20@loadbalancer' -p '10.0.2.15:32022:32022@loadbalancer' --k3s-arg "--disable=traefik@server:0"


helm install valkey valkey/valkey \
  --set dataStorage.enabled=true \
  --set dataStorage.size=2Gi \
  --set metrics.enabled=true \
  --set auth.enabled=true \
  --set auth.aclUsers.default.permissions="~* &* +@all" \
  --set auth.aclUsers.default.password=demo

kubectl apply --server-side \
  -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.28/releases/cnpg-1.28.0.yaml

kubectl rollout status deployment/cnpg-controller-manager \
  -n cnpg-system \
  --timeout=2m

kubectl apply -f pg-cluster-2.yaml
kubectl wait cluster/gitlab-rails-db --for=condition=Ready --timeout=3m

helm install garage garage/garage \
  --set persistence.data.size=5Gi \
  --set persistence.meta.size=250Mi \
  --wait

bash ./setup_garage.sh

helm install gitlab gitlab/gitlab --set gatewayApiResources.gateway.listeners.registry-web.tls.certificateRefs[0].name=gitlab-wildcard-tls --set certmanager-issuer.email=alissonmarcos250@gmail.com --set gatewayApiResources.gateway.listeners.gitlab-web.tls.certificateRefs[0].name=gitlab-wildcard-tls -f values-minikube-minimum.yaml --set gatewayApiResources.gateway.listeners.kas-web.tls.certificateRefs[0].name=gitlab-wildcard-tls --wait

export gitlab_password=$(kubectl get secret gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 -d )
printf "Gitlab were installed !\n"
printf "Open your browser at https://gitlab.10.0.2.15.nip.io\n"
printf "Login with username root and password $gitlab_password\n"
