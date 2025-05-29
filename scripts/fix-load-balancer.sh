#!/bin/bash
set -e

echo "Fixing AWS Load Balancer Controller issues"

# Delete pending and terminating pods
echo "Cleaning up stuck pods..."
kubectl delete pod -n kube-system $(kubectl get pods -n kube-system | grep aws-load-balancer-controller | grep -v Running | awk '{print $1}') --force --grace-period=0

# Scale down and up the deployment
echo "Restarting the AWS Load Balancer Controller..."
kubectl scale deployment aws-load-balancer-controller -n kube-system --replicas=0
sleep 10
kubectl scale deployment aws-load-balancer-controller -n kube-system --replicas=2

# Wait for pods to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=aws-load-balancer-controller -n kube-system --timeout=120s

# Apply ingress resources
echo "Applying ingress resources..."
kubectl apply -f k8s/ingress.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/grafana-ingress.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/prometheus-ingress.yaml --insecure-skip-tls-verify=true

echo "Load balancer controller fixed and ingress resources applied."