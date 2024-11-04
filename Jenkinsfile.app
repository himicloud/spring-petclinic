pipeline {
    agent any  // This will allow Jenkins to run on any available agent

    tools {
        maven 'Maven 3.8.7'  // Ensure Maven is configured in Global Tool Configuration
    }

    environment {
        SONAR_PROJECT_KEY = 'himicloud_spring-petclinic'
        SONAR_ORGANIZATION = 'himicloud'
        SONAR_HOST_URL = 'https://sonarcloud.io'
    }

    stages {
        stage('Preparation') {
            steps {
                // Cloning the repository, defaulting to main if BRANCH_NAME is not set
                checkout([$class: 'GitSCM', branches: [[name: "*/${env.BRANCH_NAME ?: 'main'}"]], userRemoteConfigs: [[url: 'https://github.com/himicloud/spring-petclinic.git']]])
            }
        }

        stage('Build') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
                        // Build Docker image for main branch
                        sh 'docker build -t spring-petclinic .'
                    } else {
                        // Build JAR/WAR file for feature branches
                        sh 'mvn clean package'
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
