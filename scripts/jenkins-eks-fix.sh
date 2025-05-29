#!/bin/bash
set -e

CLUSTER_NAME="ecommerce-eks-cluster"
REGION=$(aws configure get region)

echo "Fixing Jenkins to EKS connectivity for cluster: $CLUSTER_NAME"

# 1. Enable public endpoint access
echo "Enabling public endpoint access..."
aws eks update-cluster-config \
  --region $REGION \
  --name $CLUSTER_NAME \
  --resources-vpc-config endpointPublicAccess=true,publicAccessCidrs="0.0.0.0/0"

# 2. Wait for update to complete
echo "Waiting for cluster update to complete..."
aws eks wait cluster-active --name $CLUSTER_NAME --region $REGION

# 3. Update kubeconfig with the public endpoint
echo "Updating kubeconfig with public endpoint..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# 4. Deploy with insecure flag
echo "Deploying Kubernetes resources with insecure flag..."
kubectl apply -f k8s/monitoring-namespace.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/deployment.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/service.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/ingress.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/configmap.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/prometheus-config.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/prometheus-deployment.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/grafana-deployment.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/grafana-ingress.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/prometheus-ingress.yaml --insecure-skip-tls-verify=true

echo "Deployment complete. Your resources should now be available in the cluster."