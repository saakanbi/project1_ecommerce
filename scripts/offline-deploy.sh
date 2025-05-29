#!/bin/bash
set -e

# This script deploys Kubernetes manifests without requiring EKS connectivity
# It creates local manifests that can be applied later when connectivity is available

CLUSTER_NAME="ecommerce-eks-cluster"
REGION=$(aws configure get region)
NAMESPACE="monitoring"

echo "Creating local Kubernetes manifests for offline deployment..."

# Create directory for processed manifests
mkdir -p k8s-processed

# Process deployment.yaml with environment variables
echo "Processing deployment.yaml..."
cat k8s/deployment.yaml | envsubst > k8s-processed/deployment.yaml

# Copy other manifests
echo "Copying other manifests..."
cp k8s/service.yaml k8s-processed/
cp k8s/ingress.yaml k8s-processed/
cp k8s/monitoring-namespace.yaml k8s-processed/
cp k8s/configmap.yaml k8s-processed/
cp k8s/prometheus-config.yaml k8s-processed/
cp k8s/prometheus-deployment.yaml k8s-processed/
cp k8s/grafana-deployment.yaml k8s-processed/
cp k8s/grafana-ingress.yaml k8s-processed/
cp k8s/prometheus-ingress.yaml k8s-processed/

# Create a script to apply the manifests
cat > k8s-processed/apply.sh << EOF
#!/bin/bash
set -e

# Create namespace
kubectl create namespace monitoring --ignore-already-exists

# Apply core resources
kubectl apply -f deployment.yaml --validate=false
kubectl apply -f service.yaml --validate=false
kubectl apply -f ingress.yaml --validate=false

# Apply monitoring resources
kubectl apply -f configmap.yaml -n monitoring --validate=false
kubectl apply -f prometheus-config.yaml -n monitoring --validate=false
kubectl apply -f prometheus-deployment.yaml -n monitoring --validate=false
kubectl apply -f grafana-deployment.yaml -n monitoring --validate=false
kubectl apply -f grafana-ingress.yaml -n monitoring --validate=false
kubectl apply -f prometheus-ingress.yaml -n monitoring --validate=false
EOF

chmod +x k8s-processed/apply.sh

echo "Manifests prepared in k8s-processed/ directory"
echo "To apply them when connectivity is available, run:"
echo "cd k8s-processed && ./apply.sh"