#!/bin/bash
set -e

CLUSTER_NAME="ecommerce-eks-cluster"
REGION=$(aws configure get region)

echo "Restarting EKS nodes for cluster: $CLUSTER_NAME"

# Get current nodegroup details
echo "Getting nodegroup details..."
CURRENT_NODEGROUP=$(aws eks list-nodegroups --cluster-name $CLUSTER_NAME --query "nodegroups[0]" --output text)

# Get instance IDs directly
echo "Finding EC2 instances for nodegroup: $CURRENT_NODEGROUP"
INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=tag:eks:nodegroup-name,Values=$CURRENT_NODEGROUP" --query "Reservations[].Instances[].InstanceId" --output text)

if [ -z "$INSTANCE_IDS" ]; then
  echo "No instances found for nodegroup $CURRENT_NODEGROUP"
  exit 1
fi

# Restart the nodes using AWS CLI
echo "Restarting EC2 instances: $INSTANCE_IDS"
aws ec2 reboot-instances --instance-ids $INSTANCE_IDS

echo "Instances reboot command sent. Waiting 2 minutes for nodes to restart..."
sleep 120

# Check node status
echo "Checking node status..."
kubectl get nodes --insecure-skip-tls-verify=true

echo "Node restart complete. Your cluster should recover shortly."