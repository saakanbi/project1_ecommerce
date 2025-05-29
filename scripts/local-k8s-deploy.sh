#!/bin/bash
set -e

# This script deploys to a local Kubernetes cluster (minikube/kind) for testing
# Use this as an alternative when EKS connectivity is problematic

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please install kubectl first."
    exit 1
fi

# Check if a local cluster is running
if ! kubectl cluster-info &> /dev/null; then
    echo "No local Kubernetes cluster detected. Please start minikube or kind first."
    exit 1
fi

# Process deployment.yaml with environment variables
echo "Processing deployment.yaml..."
cat k8s/deployment.yaml | envsubst > k8s/deployment_processed.yaml
mv k8s/deployment_processed.yaml k8s/deployment.yaml

# Create namespace
echo "Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Apply manifests
echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/configmap.yaml -n monitoring
kubectl apply -f k8s/prometheus-config.yaml -n monitoring
kubectl apply -f k8s/prometheus-deployment.yaml -n monitoring
kubectl apply -f k8s/grafana-deployment.yaml -n monitoring

echo "Deployment completed successfully!"
echo "To access the application, run: kubectl port-forward svc/ecommerce-backend 8080:80"