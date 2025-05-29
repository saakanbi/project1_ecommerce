#!/bin/bash
set -e

# Script to establish direct connectivity to EKS cluster
echo "EKS Direct Connection Setup"
echo "=========================="

# Get cluster details
CLUSTER_NAME="ecommerce-eks-cluster"
REGION=$(aws configure get region)

echo "Getting EKS cluster endpoint..."
CLUSTER_ENDPOINT=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.endpoint" --output text)
CLUSTER_CA=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.certificateAuthority.data" --output text)

echo "Getting Jenkins instance details..."
JENKINS_INSTANCE=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=jenkins-server" --query "Reservations[0].Instances[0].InstanceId" --output text)
JENKINS_SG=$(aws ec2 describe-instances --instance-ids $JENKINS_INSTANCE --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" --output text)

echo "Getting EKS cluster security group..."
CLUSTER_SG=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" --output text)

echo "Updating security groups to allow direct connectivity..."
aws ec2 authorize-security-group-egress --group-id $JENKINS_SG --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $CLUSTER_SG --protocol tcp --port 443 --source-group $JENKINS_SG

echo "Creating direct kubeconfig..."
cat > direct-kubeconfig.yaml << EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $CLUSTER_CA
    server: $CLUSTER_ENDPOINT
  name: $CLUSTER_NAME
contexts:
- context:
    cluster: $CLUSTER_NAME
    user: jenkins
  name: jenkins-$CLUSTER_NAME
current-context: jenkins-$CLUSTER_NAME
users:
- name: jenkins
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - eks
        - get-token
        - --cluster-name
        - $CLUSTER_NAME
        - --region
        - $REGION
EOF

echo "Testing direct connection..."
export KUBECONFIG=direct-kubeconfig.yaml
kubectl get nodes

echo "If successful, copy this kubeconfig to Jenkins at /var/lib/jenkins/.kube/config"
echo "Direct connection setup complete!"