#!/bin/bash
# ================================================================
# install-tools.sh
# Installs kubectl and minikube on Arch Linux
# Run with: bash install-tools.sh
# ================================================================

set -e

echo "╔══════════════════════════════════════════════════════╗"
echo "║  ABC Technologies DevOps — Tool Installation Script  ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# 1. System packages
echo "▶ Installing system packages (netcat, bc, curl)..."
sudo pacman -Sy --noconfirm openbsd-netcat bc curl
echo "✔ System packages installed"
echo ""

# 2. kubectl
echo "▶ Installing kubectl..."
KUBE_VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt)
curl -sLO "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
echo "✔ kubectl $(kubectl version --client --short 2>/dev/null || kubectl version --client) installed"
echo ""

# 3. minikube
echo "▶ Installing minikube..."
curl -sLO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube
echo "✔ $(minikube version) installed"
echo ""

# 4. Start minikube
echo "▶ Starting Minikube (this takes 2-3 minutes)..."
minikube start --driver=docker
echo "✔ Minikube started"
echo ""

# 5. Deploy to Kubernetes
PROJECT_DIR="/home/prasannaa/Downloads/23BIT0041_Prasannaa_DevOps_Project"
echo "▶ Deploying website to Kubernetes..."
kubectl apply -f "$PROJECT_DIR/k8s/deployment.yaml"
kubectl apply -f "$PROJECT_DIR/k8s/service.yaml"
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=abc-website --timeout=120s
echo "✔ Kubernetes pods are running"
echo ""
kubectl get pods -l app=abc-website
kubectl get svc abc-website-service
echo ""

K8S_URL=$(minikube service abc-website-service --url 2>/dev/null)
echo "🌐 Website on Kubernetes: $K8S_URL"
echo ""

echo "╔══════════════════════════════════════════════════════╗"
echo "║              Installation Complete! ✅               ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Website:    http://localhost:8081                   ║"
echo "║  Kubernetes: $K8S_URL"
echo "║  Jenkins:    http://localhost:8080                   ║"
echo "║  Grafana:    http://localhost:3000  (admin/admin)    ║"
echo "║  Graphite:   http://localhost:8090                   ║"
echo "║  Nagios:     http://localhost:8082/nagios            ║"
echo "╚══════════════════════════════════════════════════════╝"
