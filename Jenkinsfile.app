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
                // Cloning the repository based on the pipeline branch
                checkout([$class: 'GitSCM', branches: [[name: "*/${env.BRANCH_NAME}"]], userRemoteConfigs: [[url: 'https://github.com/himicloud/spring-petclinic.git']]])
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
