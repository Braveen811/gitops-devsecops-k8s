#!/bin/bash
set -e

echo "[*] Installing k3s on Arch Linux..."
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --disable traefik

echo "[*] Waiting for node to be ready..."
sleep 15

echo "[*] Cluster status:"
kubectl get nodes

echo "[+] k3s bootstrap complete!"
