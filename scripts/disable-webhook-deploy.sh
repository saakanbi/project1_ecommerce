#!/bin/bash
set -e

echo "Disabling webhook validation and deploying resources"

# Disable the webhook
echo "Disabling AWS Load Balancer webhook..."
kubectl delete -A ValidatingWebhookConfiguration aws-load-balancer-webhook || true

# Apply resources
echo "Deploying resources..."
kubectl apply -f k8s/monitoring-namespace.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/deployment.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/service.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/configmap.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/prometheus-config.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/prometheus-deployment.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/grafana-deployment.yaml --insecure-skip-tls-verify=true

# Apply ingress resources
echo "Applying ingress resources..."
kubectl apply -f k8s/ingress.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/grafana-ingress.yaml --insecure-skip-tls-verify=true
kubectl apply -f k8s/prometheus-ingress.yaml --insecure-skip-tls-verify=true

echo "Checking deployment status..."
kubectl get pods -n monitoring

echo "Deployment complete."