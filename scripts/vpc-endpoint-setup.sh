#!/bin/bash
set -e

# Script to create VPC endpoints for EKS connectivity
echo "Setting up VPC endpoints for EKS connectivity"
echo "============================================="

# Get VPC ID where Jenkins and EKS are running
CLUSTER_NAME="ecommerce-eks-cluster"
VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.vpcId" --output text)
REGION=$(aws configure get region)

echo "Creating VPC endpoints for EKS in VPC: $VPC_ID, Region: $REGION"

# Get subnet IDs
SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[?MapPublicIpOnLaunch==\`false\`].SubnetId" --output text | tr '\t' ',')

# Get security group for Jenkins
JENKINS_SG=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=jenkins-server" --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" --output text)

# Create VPC endpoints for EKS
echo "Creating VPC endpoint for Amazon EKS API"
aws ec2 create-vpc-endpoint --vpc-id $VPC_ID \
  --service-name com.amazonaws.$REGION.eks \
  --vpc-endpoint-type Interface \
  --subnet-ids $(echo $SUBNET_IDS | tr ',' ' ') \
  --security-group-ids $JENKINS_SG \
  --private-dns-enabled

echo "Creating VPC endpoint for Amazon ECR API"
aws ec2 create-vpc-endpoint --vpc-id $VPC_ID \
  --service-name com.amazonaws.$REGION.ecr.api \
  --vpc-endpoint-type Interface \
  --subnet-ids $(echo $SUBNET_IDS | tr ',' ' ') \
  --security-group-ids $JENKINS_SG \
  --private-dns-enabled

echo "Creating VPC endpoint for Amazon ECR Docker"
aws ec2 create-vpc-endpoint --vpc-id $VPC_ID \
  --service-name com.amazonaws.$REGION.ecr.dkr \
  --vpc-endpoint-type Interface \
  --subnet-ids $(echo $SUBNET_IDS | tr ',' ' ') \
  --security-group-ids $JENKINS_SG \
  --private-dns-enabled

echo "Creating VPC endpoint for S3 (Gateway type)"
aws ec2 create-vpc-endpoint --vpc-id $VPC_ID \
  --service-name com.amazonaws.$REGION.s3 \
  --vpc-endpoint-type Gateway \
  --route-table-ids $(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[].RouteTableId" --output text | tr '\t' ' ')

echo "VPC endpoints created successfully!"
echo "Please allow a few minutes for the endpoints to become available."