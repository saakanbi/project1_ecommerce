pipeline {
    agent any

    environment {
        IMAGE_NAME = "ceeyit/ecommerce-backend"
    }

    tools {
        maven 'Maven 3'  // Make sure this name matches Jenkins' Maven tool config
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/your-username/project1_ecommerce.git' // Change to your actual repo
            }
        }

        stage('Build App') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME} ."
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker tag ${IMAGE_NAME} $DOCKER_USER/ecommerce-backend"
                    sh "docker push $DOCKER_USER/ecommerce-backend"
                }
            }
        }
    }

    post {
        success {
            echo 'Build and push successful!'
        }
        failure {
            echo 'Build failed.'
        }
    }
}
