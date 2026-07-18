#!/bin/bash

export YELLOW="\001\033[1;33m\002" RESET="\001\033[0m\002"

export GARAGE_NAMESPACE=default

set -xe

kubectl rollout status statefulsets.apps --timeout=300s

kubectl exec -n $GARAGE_NAMESPACE pod/garage-0 -- /garage status | awk '
/^==== HEALTHY NODES ====$/ { found=1; next }

found && $1 != "ID" && length($1) == 16 {
    print $1 > ("node_" ++n "_id.txt")
    close("node_" n "_id.txt")
    if (n == 3) exit
}
'

kubectl -n $GARAGE_NAMESPACE exec pod/garage-0 -- /garage layout assign -z gitlab1 -c 5G $(cat node_1_id.txt)
kubectl -n $GARAGE_NAMESPACE exec  pod/garage-0  -- /garage layout assign -z gitlab2 -c 5G $(cat node_2_id.txt)
kubectl -n $GARAGE_NAMESPACE exec pod/garage-0  -- /garage layout assign -z gitlab3 -c 5G $(cat node_3_id.txt)

layout_version=$(
    kubectl exec pod/garage-0 -- /garage layout show |
    awk '/^Current cluster layout version:/ {print $NF}'
)

layout_version=$(( layout_version + 1))

kubectl -n $GARAGE_NAMESPACE exec pod/garage-0  -- /garage layout apply --version $layout_version

buckets=( "gitlab-agent-plan-content" "gitlab-artifacts" "gitlab-backups" \
         "gitlab-ci-secure-files" "gitlab-dependency-proxy" "gitlab-mr-diffs" \
         "gitlab-packages" "gitlab-pages" "gitlab-terraform-state" "gitlab-uploads" \
         "registry" "runner-cache" "tmp" "git-lfs" )

for bucket in "${buckets[@]}"; do
  kubectl -n $GARAGE_NAMESPACE exec pod/garage-0 -- /garage bucket create "${bucket}";
done

KEY_OUTPUT=$(kubectl exec -n $GARAGE_NAMESPACE pod/garage-0   -- \
    /garage key create gitlab-app-key)

export GARAGE_ACCESS_KEY=$(echo "${KEY_OUTPUT}" | grep 'Key ID:' | awk '{print $3}')
export GARAGE_SECRET_KEY=$(echo "${KEY_OUTPUT}" | grep 'Secret key:' | awk '{print $3}')

printf "env var GARAGE_ACCESS_KEY: $GARAGE_ACCESS_KEY\n"
printf "env var GARAGE_SECRET_KEY: $GARAGE_SECRET_KEY\n"

for bucket in "${buckets[@]}"; do
  kubectl exec -n $GARAGE_NAMESPACE pod/garage-0  -- /garage bucket allow --read --write --key gitlab-app-key "${bucket}";
done


cat <<EOF | kubectl create secret generic gitlab-object-storage --from-file=config=/dev/stdin
provider: AWS
region: garage
aws_access_key_id: $GARAGE_ACCESS_KEY
aws_secret_access_key: $GARAGE_SECRET_KEY
endpoint: "http://garage.$GARAGE_NAMESPACE.svc.cluster.local:3900"
path_style: true
EOF

cat <<EOF | kubectl create secret generic gitlab-object-storage-s3cmd --from-file=config=/dev/stdin
[default]
access_key = $GARAGE_ACCESS_KEY
secret_key = $GARAGE_SECRET_KEY
host_base = garage.$GARAGE_NAMESPACE.svc.cluster.local:3900
host_bucket = garage.$GARAGE_NAMESPACE.svc.cluster.local:3900
use_https = False
EOF

cat <<EOF | kubectl create secret generic gitlab-registry-storage --from-file=config=/dev/stdin
s3:
  accesskey: ${GARAGE_ACCESS_KEY}
  secretkey: ${GARAGE_SECRET_KEY}
  bucket: registry
  region: garage
  regionendpoint: http://garage.${GARAGE_NAMESPACE}.svc.cluster.local:3900
  secure: false
  v4auth: true
  pathstyle: true
EOF
