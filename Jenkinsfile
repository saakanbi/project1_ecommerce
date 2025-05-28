pipeline {
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