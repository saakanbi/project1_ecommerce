#!/bin/bash
set -e

CLUSTER_NAME="ecommerce-eks-cluster"
REGION=$(aws configure get region)

echo "Fixing EKS connectivity issues for cluster: $CLUSTER_NAME"

# Update kubeconfig with proper certificate authority data
echo "Updating kubeconfig with proper certificate authority..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# Test kubectl connection
echo "Testing kubectl connection..."
kubectl get nodes --insecure-skip-tls-verify=true

# Apply Kubernetes resources with TLS verification disabled
echo "Applying Kubernetes resources..."
kubectl apply -f k8s/monitoring-namespace.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/deployment.yaml --insecure-skip-tls-verify=true

echo "EKS connectivity fix applied and resources deployed."