#!/bin/bash
set -e

CLUSTER_NAME="ecommerce-eks-cluster"
CURRENT_NODEGROUP=$(aws eks list-nodegroups --cluster-name $CLUSTER_NAME --query "nodegroups[0]" --output text)
NEW_NODEGROUP="nodegroup-fixed-$(date +%Y%m%d%H%M%S)"

echo "Getting details from current nodegroup: $CURRENT_NODEGROUP"

# Get subnet IDs as an array
SUBNET_IDS=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $CURRENT_NODEGROUP --query "nodegroup.subnets" --output text)
SUBNET_ARGS=""
for subnet in $SUBNET_IDS; do
  SUBNET_ARGS="$SUBNET_ARGS --subnets $subnet"
done

# Get node role
NODE_ROLE=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $CURRENT_NODEGROUP --query "nodegroup.nodeRole" --output text)

# Get instance type
INSTANCE_TYPE=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $CURRENT_NODEGROUP --query "nodegroup.instanceTypes[0]" --output text)

# Get scaling config
MIN_SIZE=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $CURRENT_NODEGROUP --query "nodegroup.scalingConfig.minSize" --output text)
MAX_SIZE=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $CURRENT_NODEGROUP --query "nodegroup.scalingConfig.maxSize" --output text)
DESIRED_SIZE=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $CURRENT_NODEGROUP --query "nodegroup.scalingConfig.desiredSize" --output text)

echo "Creating new nodegroup with the following details:"
echo "Cluster: $CLUSTER_NAME"
echo "New nodegroup name: $NEW_NODEGROUP"
echo "Subnets: $SUBNET_IDS"
echo "Node role: $NODE_ROLE"
echo "Instance type: $INSTANCE_TYPE"
echo "Min size: $MIN_SIZE, Max size: $MAX_SIZE, Desired size: $DESIRED_SIZE"

# Create new nodegroup
aws eks create-nodegroup \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name $NEW_NODEGROUP \
  $SUBNET_ARGS \
  --node-role $NODE_ROLE \
  --instance-types $INSTANCE_TYPE \
  --scaling-config minSize=$MIN_SIZE,maxSize=$MAX_SIZE,desiredSize=$DESIRED_SIZE

echo "Waiting for new nodegroup to become active..."
aws eks wait nodegroup-active --cluster-name $CLUSTER_NAME --nodegroup-name $NEW_NODEGROUP

echo "New nodegroup created successfully. You can now delete the old nodegroup with:"
echo "aws eks delete-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $CURRENT_NODEGROUP"