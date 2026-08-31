#!/usr/bin/env bash
set -euo pipefail

host="${DESKTOP_02_HOST:-10.0.0.56}"
output="${KUBECONFIG:-$HOME/.kube/config}"
source_config="$(mktemp)"
credentials_dir="$(mktemp -d)"
trap 'rm -f "$source_config"; rm -rf "$credentials_dir"' EXIT

install -d -m 0700 "$(dirname "$output")"
ssh -o BatchMode=yes "root@$host" 'cat /etc/rancher/k3s/k3s.yaml' > "$source_config"

KUBECONFIG="$source_config" kubectl config view --raw --minify \
  -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' \
  | openssl base64 -d -A > "$credentials_dir/ca.crt"
KUBECONFIG="$source_config" kubectl config view --raw --minify \
  -o jsonpath='{.users[0].user.client-certificate-data}' \
  | openssl base64 -d -A > "$credentials_dir/client.crt"
KUBECONFIG="$source_config" kubectl config view --raw --minify \
  -o jsonpath='{.users[0].user.client-key-data}' \
  | openssl base64 -d -A > "$credentials_dir/client.key"

kubectl --kubeconfig="$output" config set-cluster desktop-02 \
  --server="https://$host:6443" \
  --certificate-authority="$credentials_dir/ca.crt" \
  --embed-certs=true >/dev/null
kubectl --kubeconfig="$output" config set-credentials desktop-02-admin \
  --client-certificate="$credentials_dir/client.crt" \
  --client-key="$credentials_dir/client.key" \
  --embed-certs=true >/dev/null
kubectl --kubeconfig="$output" config set-context desktop-02 \
  --cluster=desktop-02 \
  --user=desktop-02-admin \
  --namespace=media >/dev/null
chmod 0600 "$output"

printf 'Installed context desktop-02 in %s\n' "$output"
