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
                withCredentials([
                    string(credentialsId: 'AWS_REGION', variable: 'AWS_REGION'),
                    string(credentialsId: 'AWS_ACCOUNT_ID', variable: 'AWS_ACCOUNT_ID')
                ]) {
                    writeFile file: 'deploy.sh', text: '''#!/bin/bash
# Configure kubectl with increased timeout
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

# Skip TLS verification
kubectl config set-cluster $CLUSTER_NAME --insecure-skip-tls-verify=true

# Update deployment image
cat k8s/deployment.yaml | envsubst > k8s/deployment_updated.yaml
mv k8s/deployment_updated.yaml k8s/deployment.yaml

# Apply manifests with validation disabled
kubectl apply -f k8s/monitoring-namespace.yaml --validate=false
kubectl apply -f k8s/deployment.yaml --validate=false
kubectl apply -f k8s/service.yaml --validate=false
kubectl apply -f k8s/ingress.yaml --validate=false
kubectl apply -f k8s/configmap.yaml -n monitoring --validate=false
kubectl apply -f k8s/prometheus-config.yaml -n monitoring --validate=false
kubectl apply -f k8s/prometheus-deployment.yaml -n monitoring --validate=false
kubectl apply -f k8s/grafana-deployment.yaml -n monitoring --validate=false
kubectl apply -f k8s/grafana-ingress.yaml -n monitoring --validate=false
kubectl apply -f k8s/prometheus-ingress.yaml -n monitoring --validate=false
'''
                    sh 'chmod +x deploy.sh'
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
