#!/usr/bin/bash

export YELLOW="\001\033[1;33m\002" RESET="\001\033[0m\002"
PORT=9000

set -e

logger() {
    printf "$YELLOW$1$RESET\n"
}

# call script to check and install dependencies
./install_dependencies.sh

# create k3d cluster and point redirect traffic from port 8888 to internal port 80 (Traefik load balancer)
logger "Creating k3d cluster"
k3d cluster create vde-frei

# create argocd and dev namespace
logger "Creating argocd and dev namespace"
kubectl create namespace argocd
kubectl create namespace dev

logger "Installing argocd"
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 10

logger "Port-forwarding argocd to $PORT"
kubectl port-forward -n argocd service/argocd-server $PORT:443 &

logger "Getting argocd secret..."
export ARGOCD_SECRET=$(argocd admin initial-password -n argocd)
logger "Argocd secret fetched and stored in ARGOCD_SECRET in your environment. $ARGOCD_SECRET"

logger "Logging in to argocd"
argocd login localhost:$PORT --username admin --password $ARGOCD_SECRET

APP_PORT=4242
logger "Creating will-playground app"
argocd app create will-playground --file confs/will42.yaml

logger "Port-forwarding dev to $APP_PORT"
PID_APP=$(kubectl port-forward -n dev service/will-playground $APP_PORT:8888 & echo $!)&
echo "Dev port-forward PID: $PID_APP"

logger "Waiting for app to be ready"
argocd app wait will-playground --timeout 30s

logger "App is ready"

logger "Opening browser to argocd"
open "https://localhost:$APP_PORT"

# TODO: Validate script in macos and linux on vm.
