#!/bin/bash
set -e

CLUSTER_NAME="ecommerce-eks-cluster"
REGION=$(aws configure get region)

# Get Jenkins instance details
echo "Getting Jenkins instance details..."
JENKINS_INSTANCE=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=jenkins-server" --query "Reservations[0].Instances[0].InstanceId" --output text)
JENKINS_SG=$(aws ec2 describe-instances --instance-ids $JENKINS_INSTANCE --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" --output text)
JENKINS_IP=$(aws ec2 describe-instances --instance-ids $JENKINS_INSTANCE --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

# Get EKS cluster security group
echo "Getting EKS cluster security group..."
CLUSTER_SG=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --output text)

# Update EKS cluster security group to allow traffic from Jenkins
echo "Updating EKS cluster security group to allow traffic from Jenkins..."
aws ec2 authorize-security-group-ingress --group-id $CLUSTER_SG --protocol tcp --port 443 --cidr $JENKINS_IP/32 || echo "Rule may already exist"

echo "Security groups updated successfully!"