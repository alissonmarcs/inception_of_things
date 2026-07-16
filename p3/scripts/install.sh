#!/usr/bin/bash

export YELLOW="\001\033[1;33m\002" RESET="\001\033[0m\002"
PORT=9000

set -ex

logger() {
    printf "$YELLOW$1$RESET\n"
}

# call script to check and install dependencies
./install_dependencies.sh

# create k3d cluster and point redirect traffic from port 8888 to internal port 80 (Traefik load balancer)
logger "Creating k3d cluster"
k3d cluster create   -p "30888:30888@server:0"

# create argocd and dev namespace
logger "Creating argocd and dev namespace"
kubectl create namespace argocd
kubectl create namespace dev

logger "Installing argocd"
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

logger "Waiting for argocd to be ready"
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

logger "Port-forwarding argocd to $PORT"
kubectl port-forward service/argocd-server -n argocd $PORT:443 > /dev/null 2>&1 &

logger "\t\t --- PID of command 'kubectl port-forward service/argocd-server': $!"

logger "Getting argocd secret..."
export ARGOCD_SECRET=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
logger "Argocd secret fetched and stored in ARGOCD_SECRET in your environment. $ARGOCD_SECRET"

logger "Logging in to argocd"
argocd login localhost:$PORT --insecure --username admin --password $ARGOCD_SECRET

logger "Creating will-playground app"
kubectl apply -f ../confs/will42.yaml -n argocd

logger "App is ready"

logger "Opening browser to argocd"
open "https://localhost:$PORT"
