#!/bin/bash
set -e

echo "Fixing Grafana deployment"

# Create a patch file for Grafana deployment
cat << EOF > /tmp/grafana-patch.yaml
spec:
  template:
    spec:
      containers:
      - name: grafana
        env:
        - name: GF_INSTALL_PLUGINS
          value: ""
        - name: GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS
          value: "true"
EOF

# Apply the patch
kubectl patch deployment grafana -n monitoring --patch "$(cat /tmp/grafana-patch.yaml)"

# Wait for the new pod to be created
echo "Waiting for Grafana pod to restart..."
sleep 10

# Check the status
kubectl get pods -n monitoring

echo "Grafana patch applied. Check the pod status to confirm it's running."