pipeline {
<<<<<<< HEAD
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
                        sed -i 's|\\${AWS_ACCOUNT_ID}|${AWS_ACCOUNT_ID}|g' k8s/deployment.yaml
                        sed -i 's|\\${AWS_REGION}|${AWS_REGION}|g' k8s/deployment.yaml
                        
                        # Apply Kubernetes manifests
                        kubectl apply -f k8s/monitoring-namespace.yaml
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        kubectl apply -f k8s/ingress.yaml
                        kubectl apply -f k8s/configmap.yaml
                        kubectl apply -f k8s/prometheus-config.yaml
                        kubectl apply -f k8s/prometheus-deployment.yaml
                        kubectl apply -f k8s/grafana-deployment.yaml
                        kubectl apply -f k8s/grafana-ingress.yaml
                        kubectl apply -f k8s/prometheus-ingress.yaml
                        
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
=======
  agent { label 'agent1' }

  environment {
    IMAGE_NAME = "ceeyit/ecommerce-backend"
    IMAGE_TAG = "${BUILD_NUMBER}"  // For version traceability
    JAVA_HOME = "/usr/lib/jvm/java-21-amazon-corretto"
    MAVEN_HOME = "/opt/apache-maven-3.9.6"
    PATH = "${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${env.PATH}"
  }

  stages {
    stage('Verify Agent') {
      steps {
        sh 'hostname'
        sh 'java -version'
        sh 'mvn -version'
        sh 'docker --version'
      }
    }

    stage('Checkout') {
      steps {
        // Use this for classic pipeline:
        checkout([$class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[
            url: 'https://github.com/saakanbi/project1_ecommerce.git',
            credentialsId: 'github-https-creds'
          ]]
        ])
        
        // Or replace the above with this if you're using multibranch pipeline:
        // checkout scm
      }
    }

    stage('Build App') {
      steps {
        sh 'mvn clean package'
      }
    }

    stage('Run Tests') {
      steps {
        sh 'mvn test'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
      }
    }

    stage('Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          script {
            echo "✅ Docker image built: ${IMAGE_NAME}:${IMAGE_TAG}"
            echo "🔐 Logging in to DockerHub as $DOCKER_USER..."

            sh """
              echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
              docker tag ${IMAGE_NAME}:${IMAGE_TAG} \$DOCKER_USER/ecommerce-backend:${IMAGE_TAG}
              docker push \$DOCKER_USER/ecommerce-backend:${IMAGE_TAG}
              docker logout
            """
          }
        }
      }
    }
  }

  post {
    success {
      echo '✅ Build and push successful!'
      cleanWs()
    }
    failure {
      echo '❌ Build failed.'
      cleanWs()
    }
  }
}
// This Jenkinsfile is designed for a classic pipeline setup.
// It includes stages for verifying the agent, checking out code, building the application,
// running tests, building a Docker image, and pushing it to DockerHub.
// Make sure to replace the credentials IDs with your actual Jenkins credentials.
// The pipeline uses environment variables for the image name and tag, Java home, and Maven home.
// It also includes post-build actions to clean the workspace and provide success/failure messages.
// Ensure that the Jenkins agent has Docker installed and configured properly.
>>>>>>> 943ee0b81e73be5ba97817c57c11e5f82a79519b
