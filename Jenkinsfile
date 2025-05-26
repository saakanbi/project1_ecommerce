pipeline {
  agent { label 'agent1' }

  environment {
    IMAGE_NAME = "ceeyit/ecommerce-backend"
  }

  tools {
    maven 'Maven 3' // Matches Global Tool Config
  }

  stages {
    stage('Verify Agent') {
      steps {
        sh 'hostname'
        sh 'java -version'
        sh 'docker --version'
      }
    }

    stage('Checkout') {
      steps {
        checkout([$class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[
            url: 'https://github.com/saakanbi/project1_ecommerce.git',
            credentialsId: 'github-https-creds'
          ]]
        ])
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
      echo '✅ Build and push successful!'
    }
    failure {
      echo '❌ Build failed.'
    }
  }
}
// This Jenkinsfile defines a pipeline for building and pushing a Docker image for an e-commerce backend application.
