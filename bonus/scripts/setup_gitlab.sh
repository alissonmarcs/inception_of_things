#!/bin/bash

#set -ex

k3d cluster create -p '10.0.2.15:30777:30777@server:0' -p '10.0.2.15:30888:30888@server:0' -p '10.0.2.15:443:443@loadbalancer' -p '10.0.2.15:80:80@loadbalancer' -p '10.0.2.15:20:20@loadbalancer' -p '10.0.2.15:32022:32022@loadbalancer' --k3s-arg "--disable=traefik@server:0"


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

helm install gitlab gitlab/gitlab --set gatewayApiResources.gateway.listeners.registry-web.tls.certificateRefs[0].name=gitlab-wildcard-tls --set certmanager-issuer.email=alissonmarcos250@gmail.com --set gatewayApiResources.gateway.listeners.gitlab-web.tls.certificateRefs[0].name=gitlab-wildcard-tls -f values-minikube-minimum.yaml --set gatewayApiResources.gateway.listeners.kas-web.tls.certificateRefs[0].name=gitlab-wildcard-tls --wait --timeout 15m

kubectl get secret gitlab-wildcard-tls-ca -o jsonpath='{.data.cfssl_ca}' | base64 -d > gitlab_ca.crt
sudo cp gitlab_ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates

kubectl create namespace argocd
kubectl create namespace dev

kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

kubectl patch service/argocd-server -n argocd --type=json -p '[{"op": "replace", "path": "/spec/type", "value": "NodePort"}, {"op":"add", "path":"/spec/ports/1/nodePort", "value":30777}]'


kubectl patch cm argocd-cm -n argocd --type merge -p '{"data":{"timeout.reconciliation":"30s"}}'
kubectl patch cm argocd-cm -n argocd --type merge -p '{"data":{"timeout.reconciliation.jitter":"0"}}'

kubectl rollout restart deployment -n argocd
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

export KEY=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
printf "Argocd password to login in browser: $KEY\n"

until argocd login 10.0.2.15:30777 \
    --username admin \
    --password "$KEY" \
    --skip-test-tls \
    --insecure; do

    echo "Argo CD is not ready yet..."
    sleep 2
done

argocd cert add-tls gitlab.10.0.2.15.nip.io --from /usr/local/share/ca-certificates/gitlab_ca.crt

export gitlab_password=$(kubectl get secret gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 -d )
printf "Gitlab were installed !\n"
printf "Open your browser at https://gitlab.10.0.2.15.nip.io\n"
printf "Login with username root and password $gitlab_password\n"
