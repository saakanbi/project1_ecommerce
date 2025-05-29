#!/bin/bash
set -e

# Script to troubleshoot and fix EKS connectivity issues
echo "EKS Connectivity Troubleshooting Script"
echo "======================================="

# 1. Check AWS CLI configuration
echo "Checking AWS CLI configuration..."
aws sts get-caller-identity

# 2. Check VPC networking configuration for Jenkins and EKS
echo "Checking EKS cluster details..."
CLUSTER_NAME="ecommerce-eks-cluster"
aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig"

# 3. Check security groups
echo "Checking security groups..."
VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.vpcId" --output text)
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[*].[GroupId,GroupName]"

# 4. Update Jenkins security group to allow outbound traffic to EKS
echo "Getting Jenkins instance details..."
JENKINS_INSTANCE=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=jenkins-server" --query "Reservations[0].Instances[0].InstanceId" --output text)
JENKINS_SG=$(aws ec2 describe-instances --instance-ids $JENKINS_INSTANCE --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" --output text)

echo "Getting EKS cluster security group..."
CLUSTER_SG=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --output text)

echo "Updating Jenkins security group to allow outbound traffic to EKS cluster..."
aws ec2 authorize-security-group-egress --group-id $JENKINS_SG --protocol all --port 443 --source-group $CLUSTER_SG

echo "Updating EKS cluster security group to allow inbound traffic from Jenkins..."
aws ec2 authorize-security-group-ingress --group-id $CLUSTER_SG --protocol all --port 443 --source-group $JENKINS_SG

# 5. Check network connectivity
echo "Testing network connectivity to EKS API server..."
API_ENDPOINT=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.endpoint" --output text | sed 's/https:\/\///')
nc -zv $API_ENDPOINT 443

# 6. Update kubeconfig and test connection
echo "Updating kubeconfig..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $(aws configure get region)

echo "Testing kubectl connection..."
kubectl get nodes

echo "Connectivity troubleshooting complete!"