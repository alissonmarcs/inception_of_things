#!/usr/bin/bash

buckets=("git-lfs" "gitlab-agent-plan-content" "gitlab-artifacts" "gitlab-backups" \
         "gitlab-ci-secure-files" "gitlab-dependency-proxy" "gitlab-mr-diffs" \
         "gitlab-packages" "gitlab-pages" "gitlab-terraform-state" "gitlab-uploads" \
         "registry" "runner-cache" "tmp" )
for bucket in "${buckets[@]}"; do
  kubectl exec -n garage pod/garage-0  -- /garage bucket allow --read --write --key gitlab-app-key "${bucket}";
done
