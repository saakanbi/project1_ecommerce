#!/bin/bash
set -e

CLUSTER_NAME="ecommerce-eks-cluster"
REGION=$(aws configure get region)

echo "Fixing EKS connectivity issues for cluster: $CLUSTER_NAME"

# 1. Enable public endpoint access temporarily
echo "Enabling public endpoint access..."
aws eks update-cluster-config \
  --region $REGION \
  --name $CLUSTER_NAME \
  --resources-vpc-config endpointPublicAccess=true,publicAccessCidrs="0.0.0.0/0"

# 2. Update kubeconfig
echo "Updating kubeconfig..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# 3. Wait for cluster update to complete
echo "Waiting for cluster update to complete..."
aws eks wait cluster-active --name $CLUSTER_NAME --region $REGION

echo "EKS connectivity fix applied. Try deploying again."