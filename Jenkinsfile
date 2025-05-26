pipeline {
  agent { label 'agent1' }

environment {
  IMAGE_NAME = "ceeyit/ecommerce-backend"
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

    stage('Run Tests') {
      steps {
        sh 'mvn test'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh "docker build -t ${IMAGE_NAME} ."
      }
    }

    stage('Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
          sh "docker tag ${IMAGE_NAME} $DOCKER_USER/ecommerce-backend"
          sh 'echo "✅ Docker image built: ${IMAGE_NAME}"'
          sh 'echo "🔐 Logging in to DockerHub..."'
          sh "docker push $DOCKER_USER/ecommerce-backend"
          sh 'docker logout'
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
// This Jenkinsfile defines a pipeline for building and deploying a Java-based e-commerce backend application.