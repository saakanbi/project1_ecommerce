#!/bin/bash
set -e

CLUSTER_NAME="ecommerce-eks-cluster"
REGION=$(aws configure get region)

echo "Fixing security group rules for Jenkins to EKS connectivity"

# Get Jenkins instance details
echo "Getting Jenkins instance details..."
JENKINS_INSTANCE=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=jenkins-server" --query "Reservations[0].Instances[0].InstanceId" --output text)
JENKINS_SG=$(aws ec2 describe-instances --instance-ids $JENKINS_INSTANCE --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" --output text)
JENKINS_VPC=$(aws ec2 describe-instances --instance-ids $JENKINS_INSTANCE --query "Reservations[0].Instances[0].VpcId" --output text)

# Get EKS cluster security group
echo "Getting EKS cluster security group..."
CLUSTER_SG=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --output text)

echo "Adding security group rules..."
# Allow Jenkins to access EKS cluster
aws ec2 authorize-security-group-egress --group-id $JENKINS_SG --protocol tcp --port 443 --cidr 0.0.0.0/0 || true
# Allow EKS cluster to receive traffic from Jenkins
aws ec2 authorize-security-group-ingress --group-id $CLUSTER_SG --protocol tcp --port 443 --source-group $JENKINS_SG || true

echo "Security group rules updated. Deploying resources..."

# Deploy with insecure flag
kubectl apply -f k8s/monitoring-namespace.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/deployment.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/service.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/ingress.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/configmap.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/prometheus-config.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/prometheus-deployment.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/grafana-deployment.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/grafana-ingress.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/prometheus-ingress.yaml --insecure-skip-tls-verify=true

echo "Deployment complete."