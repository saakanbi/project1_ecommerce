#!/bin/bash
set -e

CLUSTER_NAME="ecommerce-eks-cluster"
REGION=$(aws configure get region)

# Get EKS cluster endpoint
echo "Getting EKS cluster endpoint..."
CLUSTER_ENDPOINT=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.endpoint" --output text | sed 's|https://||')

# Get Jenkins instance details
echo "Getting Jenkins instance details..."
JENKINS_INSTANCE=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=jenkins-server" --query "Reservations[0].Instances[0].InstanceId" --output text)
JENKINS_IP=$(aws ec2 describe-instances --instance-ids $JENKINS_INSTANCE --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

echo "Jenkins IP: $JENKINS_IP"
echo "EKS Endpoint: $CLUSTER_ENDPOINT"

# SSH into Jenkins and test connectivity
echo "To test connectivity from Jenkins, run:"
echo "ssh ec2-user@$JENKINS_IP 'curl -k https://$CLUSTER_ENDPOINT'"
echo "or"
echo "ssh ec2-user@$JENKINS_IP 'nc -zv $CLUSTER_ENDPOINT 443'"