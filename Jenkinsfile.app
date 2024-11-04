pipeline {
    agent any  // This will allow Jenkins to run on any available agent

    tools {
        maven 'Maven 3.8.7'  // Ensure Maven is configured in Global Tool Configuration
    }

    environment {
        SONAR_PROJECT_KEY = 'himicloud_spring-petclinic'
        SONAR_ORGANIZATION = 'himicloud'
        SONAR_HOST_URL = 'https://sonarcloud.io'
        SONAR_TOKEN = credentials('sonar_token')  // SonarCloud token from Jenkins credentials
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
                        echo "Docker image created for main branch."
                    } else {
                        // Build JAR/WAR file for feature branches
                        sh 'mvn clean package'
                        echo "JAR/WAR file created for feature branch."
                    }
                }
            }
        }

        stage('Code Quality Checks') {
            parallel {
                stage('Snyk Scan') {
                    environment {
                        SNYK_TOKEN = credentials('snyk_token')  // Snyk token from Jenkins credentials
                    }
                    steps {
                        // Authenticate with Snyk and run the scan
                        sh 'snyk auth $SNYK_TOKEN'
                        sh 'snyk test'
                    }
                }
                stage('SonarCloud Analysis') {
                    environment {
                        SONAR_TOKEN = credentials('sonar_token')  // SonarCloud token from Jenkins credentials
                    }
                    steps {
                        script {
                            def scannerHome = tool 'SonarQubeScanner'  // Ensure SonarQube Scanner is configured in Jenkins
                            withSonarQubeEnv('SonarCloud') {
                                sh """
                                    ${scannerHome}/bin/sonar-scanner \
                                    -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                    -Dsonar.organization=${SONAR_ORGANIZATION} \
                                    -Dsonar.sources=. \
                                    -Dsonar.host.url=${SONAR_HOST_URL} \
                                    -Dsonar.token=$SONAR_TOKEN \
                                    -Dsonar.java.binaries=target/classes
                                """
                            }
                        }
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
