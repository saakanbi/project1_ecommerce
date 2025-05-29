#!/bin/bash
set -e

CLUSTER_NAME="ecommerce-eks-cluster"
REGION=$(aws configure get region)

# Get the EKS endpoint
ENDPOINT=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query "cluster.endpoint" --output text)

echo "Testing connectivity to EKS endpoint: $ENDPOINT"
echo "---------------------------------------------"

# Test with curl
echo "Testing with curl:"
curl -v $ENDPOINT

# Test with nc (netcat)
echo -e "\nTesting with netcat:"
HOSTNAME=$(echo $ENDPOINT | sed 's|https://||')
nc -zv $HOSTNAME 443

echo -e "\nIf both tests fail, check your security groups and network ACLs"