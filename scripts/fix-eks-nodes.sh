#!/bin/bash
set -e

CLUSTER_NAME="ecommerce-eks-cluster"
REGION=$(aws configure get region)

echo "Fixing EKS node issues for cluster: $CLUSTER_NAME"

# Get current nodegroup details
echo "Getting current nodegroup details..."
CURRENT_NODEGROUP=$(aws eks list-nodegroups --cluster-name $CLUSTER_NAME --query "nodegroups[0]" --output text)
NODE_ROLE=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $CURRENT_NODEGROUP --query "nodegroup.nodeRole" --output text)

# Cordon and drain the problematic nodes
echo "Cordoning and draining problematic nodes..."
kubectl cordon ip-10-0-1-58.ec2.internal ip-10-0-2-182.ec2.internal --insecure-skip-tls-verify=true
kubectl drain ip-10-0-1-58.ec2.internal ip-10-0-2-182.ec2.internal --ignore-daemonsets --delete-emptydir-data --force --insecure-skip-tls-verify=true

# Restart the nodes using AWS CLI
echo "Restarting EC2 instances..."
INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=tag:eks:nodegroup-name,Values=$CURRENT_NODEGROUP" --query "Reservations[].Instances[].InstanceId" --output text)
aws ec2 reboot-instances --instance-ids $INSTANCE_IDS

echo "Waiting for nodes to restart (60 seconds)..."
sleep 60

# Check node status
echo "Checking node status..."
kubectl get nodes --insecure-skip-tls-verify=true

echo "Node restart complete. If nodes are still not Ready, you may need to recreate the nodegroup."