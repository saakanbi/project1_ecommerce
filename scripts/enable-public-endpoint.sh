#!/bin/bash
set -e

# Enable public endpoint access for EKS cluster
CLUSTER_NAME="ecommerce-eks-cluster"
REGION=$(aws configure get region)

echo "Enabling public endpoint access for EKS cluster: $CLUSTER_NAME"
aws eks update-cluster-config \
  --region $REGION \
  --name $CLUSTER_NAME \
  --resources-vpc-config endpointPublicAccess=true,publicAccessCidrs="0.0.0.0/0"

echo "Waiting for update to complete..."
aws eks wait cluster-active --name $CLUSTER_NAME --region $REGION

echo "Public endpoint enabled successfully!"