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
            steps {
                script {
                    sh """
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ecommerce-eks-cluster
                        
                        # Update deployment image
                        sed -i 's|\\${AWS_ACCOUNT_ID}|'${AWS_ACCOUNT_ID}'|g' k8s/deployment.yaml
                        sed -i 's|\\${AWS_REGION}|'${AWS_REGION}'|g' k8s/deployment.yaml
                        
                        # Apply Kubernetes manifests
                        kubectl apply -f k8s/monitoring-namespace.yaml
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        kubectl apply -f k8s/ingress.yaml
                        kubectl apply -f k8s/configmap.yaml -n monitoring
                        kubectl apply -f k8s/prometheus-config.yaml -n monitoring
                        kubectl apply -f k8s/prometheus-deployment.yaml -n monitoring
                        kubectl apply -f k8s/grafana-deployment.yaml -n monitoring
                        kubectl apply -f k8s/grafana-ingress.yaml -n monitoring
                        kubectl apply -f k8s/prometheus-ingress.yaml -n monitoring
                        
                        # Wait for deployment to complete
                        kubectl rollout status deployment/ecommerce-backend
                    """
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
