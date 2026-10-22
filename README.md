```markdown
## Automated GitOps & DevSecOps Delivery Pipeline on K3s

![CI/CD Pipeline](https://github.com/Braveen811/gitops-devsecops-k8s/actions/workflows/ci.yml/badge.svg)
![Security: Trivy](https://img.shields.io/badge/Security-Trivy%20%7C%20Gitleaks-red)
![Platform: Arch Linux](https://img.shields.io/badge/Platform-Arch%20Linux-blue?logo=arch-linux)
![Orchestration: K3s](https://img.shields.io/badge/Cluster-k3s-informational?logo=kubernetes)
![Engine: ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-orange?logo=argo)

A production-grade, end-to-end GitOps and DevSecOps pipeline implemented natively on **Arch Linux**. This project automates security scanning, container image building, vulnerability assessment, and continuous delivery to a lightweight local Kubernetes cluster using **ArgoCD**.

---

## 🏗️ Architecture Flow

```text
 Developer (Arch Linux)
    │
    ▼ (git push)
 GitHub Repository
    │
    ▼ triggers
 GitHub Actions Workflow (.github/workflows/ci.yml)
    ├── Gitleaks: Scans Git history for leaks/keys
    ├── Docker Build: Hardened multi-stage container build
    ├── Trivy: Scans container image for vulnerabilities (CRITICAL, HIGH)
    └── Push: Deploys signed image to GHCR (ghcr.io/braveen811/gitops-devsecops-k8s)
    │
    ▼ continuously reconciles
 ArgoCD GitOps Controller (Inside k3s)
    └── Pulls k8s/overlays/dev declarations
        └── Deploys pod in `dev-environment` with zero-trust SecurityContext

```

---

## 🚀 Tech Stack & Tooling

* **Operating System:** Arch Linux
* **Container Orchestration:** k3s (Lightweight Kubernetes)
* **GitOps Continuous Delivery:** ArgoCD
* **CI/CD Automation:** GitHub Actions
* **Security Scanning:** Gitleaks (Secret detection) & Trivy (Vulnerability scanning)
* **Container Registry:** GitHub Container Registry (GHCR)
* **Application:** Node.js & Express microservice with Prometheus metrics telemetry (`prom-client`)

---

## 🛡️ Security Model & Hardening

* **Non-Root Execution:** Container processes execute strictly under UID `1000` (unprivileged `node` user).
* **Immutable Root Filesystem:** Root filesystem mounted as read-only (`readOnlyRootFilesystem: true`) to prevent malicious runtime persistence.
* **Linux Capabilities:** All Linux kernel capabilities dropped (`drop: ["ALL"]`) with `allowPrivilegeEscalation: false`.
* **CI Quality Gate:** Build pipeline fails unconditionally if secrets are committed or if `CRITICAL`/`HIGH` vulnerabilities are discovered during image scanning.

---

## 📁 Repository Structure

```text
gitops-devsecops-k8s/
├── .github/
│   └── workflows/
│       └── ci.yml               # GitHub Actions DevSecOps pipeline
├── app/
│   ├── Dockerfile               # Hardened multi-stage container build
│   ├── package.json             # Node.js dependencies
│   └── src/
│       └── server.js            # Express server with /health and /metrics
├── argocd/
│   └── application.yaml         # ArgoCD GitOps application manifest
├── k8s/
│   ├── base/                    # Base Kubernetes manifests (Deployment, Service)
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── kustomization.yaml
│   └── overlays/
│       └── dev/                 # Environment-specific Kustomize overlays
│           └── kustomization.yaml
└── scripts/
    └── bootstrap-k3s.sh         # Automated k3s cluster setup script

```

---

## ⚙️ Quick Start Guide

### 1. Bootstrap the Local Cluster

Install and configure a lightweight k3s cluster with Traefik disabled:

```bash
chmod +x scripts/bootstrap-k3s.sh
./scripts/bootstrap-k3s.sh

```

### 2. Deploy ArgoCD

Install ArgoCD using server-side apply to bypass CRD size limits:

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f [https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml](https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml) --server-side --force-conflicts

```

### 3. Connect the GitOps Pipeline

Register the repository overlay with ArgoCD:

```bash
kubectl apply -f argocd/application.yaml

```

### 4. Verify Active Deployment

Watch ArgoCD pull the image and bring up the application:

```bash
kubectl get pods -n dev-environment -w

```

### 5. Access & Telemetry Verification

Expose the service locally using port forwarding:

```bash
kubectl port-forward svc/telemetry-backend-svc 8080:80 -n dev-environment

```

From a secondary terminal, verify the application endpoints:

```bash
curl -s http://localhost:8080/health
curl -s http://localhost:8080/metrics

```

---

## 🛠️ Custom Tweaks & Fixes in this Build

### 1. Kubernetes CRD Annotation Limit Bypass (`--server-side`)

* **Problem:** Standard `kubectl apply` commands for ArgoCD fail with `metadata.annotations: Too long: may not be more than 262144 bytes`.
* **Root Cause:** Client-side `kubectl apply` attempts to store the entire manifest into an annotation, exceeding the 256 KB Kubernetes metadata limit.
* **Fix:** Applied manifests using `--server-side` to let the Kubernetes API server manage field ownership directly.

### 2. GHCR Anonymous Pull Authorization (403 Forbidden)

* **Problem:** Pods stuck in `ErrImagePull` with the event log: `failed to fetch anonymous token... 403 Forbidden`.
* **Root Cause:** Newly published GitHub Container Registry (GHCR) packages default to private visibility.
* **Fix:** Updated package visibility in GitHub settings from **Private** to **Public**, removing the need for an explicit `imagePullSecrets` configuration on the local k3s cluster.

### 3. Strict YAML Formatting & Parser Alignment

* **Problem:** `kubectl apply` rejected the deployment manifest due to detached list indicators (`-`).
* **Fix:** Reformatted the container declaration block to maintain standard 2-space indentation and aligned list items inline (`- name: telemetry-backend`).

---

## 🔧 System Tweaks (Troubleshooting)

### Forcing Immediate Pod Cycle

When waiting for Kubernetes exponential backoff (`ImagePullBackOff`), force an immediate redeployment:

```bash
kubectl delete pod --all -n dev-environment
kubectl get pods -n dev-environment -w

```

### Inspecting Image Pull Events

If a container fails to pull, check the raw scheduler and kubelet events:

```bash
kubectl describe pod <pod-name> -n dev-environment | tail -n 15

```

---

## ✌️ Wrapping Up

This project bridges local Arch Linux kernel performance with modern cloud-native GitOps delivery:

* **Fully Automated Shift-Left Security:** No image reaches the registry without passing Gitleaks and Trivy checks.
* **Self-Healing Declarative State:** ArgoCD continuously monitors repository manifests and maintains cluster convergence without manual `kubectl` intervention.
* **Production-Hardened Pods:** Zero-privilege execution environment blocking root compromises and filesystem writes out of the box.

---

**Author:** [Braveen R](https://braveenr.linklee.in/))</br>
EOF

---
