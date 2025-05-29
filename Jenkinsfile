pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = credentials('AWS_ACCOUNT_ID')
        AWS_REGION = credentials('AWS_REGION')
        ECR_REPOSITORY = "ecommerce-backend"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        
        stage('Build and Push Docker Image') {
            steps {
                script {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                        docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} .
                        docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}
                        docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:latest
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:latest
                    """
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            environment {
                CLUSTER_NAME = "ecommerce-eks-cluster"
            }
            steps {
                // Create deployment script
                writeFile file: 'deploy.sh', text: '''#!/bin/bash
set -e

# Update kubeconfig
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

# Update deployment image
cat k8s/deployment.yaml | envsubst > k8s/deployment_updated.yaml
mv k8s/deployment_updated.yaml k8s/deployment.yaml

# Try direct connection without proxy
echo "Testing connection to Kubernetes API server..."
kubectl get namespaces --request-timeout=180s || {
    echo "Direct connection failed, trying with AWS VPC endpoints..."
    # Apply manifests with retry logic
    for i in {1..3}; do
        if kubectl apply -f k8s/monitoring-namespace.yaml --validate=false; then
            break
        fi
        echo "Attempt $i failed, retrying in 10 seconds..."
        sleep 10
    done
}

# Create monitoring namespace if it doesn't exist
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f - || true

# Apply core resources with retry logic
for manifest in deployment service ingress; do
    kubectl apply -f k8s/$manifest.yaml --validate=false
done

# Apply monitoring resources
for manifest in configmap prometheus-config prometheus-deployment grafana-deployment grafana-ingress prometheus-ingress; do
    kubectl apply -f k8s/$manifest.yaml -n monitoring --validate=false || true
done

# Wait for deployment to complete
kubectl rollout status deployment/ecommerce-backend --timeout=180s || true
'''
                
                sh 'chmod +x deploy.sh'
                withCredentials([
                    string(credentialsId: 'AWS_REGION', variable: 'AWS_REGION'),
                    string(credentialsId: 'AWS_ACCOUNT_ID', variable: 'AWS_ACCOUNT_ID')
                ]) {
                    sh './deploy.sh'
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    sh """
                        # Wait for services to be available
                        echo "Waiting for services to be available..."
                        sleep 30
                        
                        # Get service endpoints
                        echo "Application endpoint:"
                        kubectl get ingress ecommerce-backend-ingress
                        
                        echo "Prometheus endpoint:"
                        kubectl get ingress prometheus-ingress -n monitoring
                        
                        echo "Grafana endpoint:"
                        kubectl get ingress grafana-ingress -n monitoring
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
// This Jenkinsfile defines a CI/CD pipeline for an e-commerce backend application.
