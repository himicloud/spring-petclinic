pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_credential')
        AWS_SECRET_ACCESS_KEY = credentials('aws_credential')
        SONAR_PROJECT_KEY = 'himicloud_spring-petclinic'
        SONAR_ORGANIZATION = 'himicloud'
        SONAR_HOST_URL = 'https://sonarcloud.io'
        SONAR_LOGIN = credentials('sonar-token')  // SonarCloud token from Jenkins credentials
    }

    stages {
        stage('Preparation') {
            steps {
                script {
                    // Cloning the repository
                    checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: 'https://github.com/himicloud/spring-petclinic.git']]])
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
                    steps {
                        script {
                            def scannerHome = tool 'SonarQubeScanner'  // Ensure SonarQube Scanner is configured in Jenkins
                            withSonarQubeEnv('SonarQubeScanner') {
                                sh """
                                    ${scannerHome}/bin/sonar-scanner \
                                    -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                    -Dsonar.organization=${SONAR_ORGANIZATION} \
                                    -Dsonar.sources=. \
                                    -Dsonar.host.url=${SONAR_HOST_URL} \
                                    -Dsonar.login=${SONAR_LOGIN}
                                """
                            }
                        }
                    }
                }
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

        stage('AWS Configuration Check') {
            steps {
                // Check AWS credentials by listing S3 buckets
                sh 'aws s3 ls'
            }
        }

        stage('Publish Artifacts') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
                        // Push Docker image to repository
                        sh 'docker tag spring-petclinic:latest your-repo/spring-petclinic:latest'
                        sh 'docker push your-repo/spring-petclinic:latest'
                    } else {
                        // Upload JAR/WAR file to JFrog Artifactory or S3
                        sh 'jfrog rt u target/*.jar your-artifactory-repo/path'
                    }
                }
            }
        }

        stage('Differentiated Tagging') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
                        echo "Tagging as production-ready"
                    } else {
                        echo "Tagging as feature branch"
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
