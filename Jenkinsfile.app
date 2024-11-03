pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_credential').accessKey
        AWS_SECRET_ACCESS_KEY = credentials('aws_credential').secretKey
    }

    stages {
        stage('Preparation') {
            steps {
                script {
                    // Cloning the repository into the 'ansible' directory as specified
                    checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: 'https://github.com/himicloud/spring-petclinic.git']]])
                }
            }
        }

        stage('Code Quality Checks') {
            parallel {
                stage('Snyk Scan') {
                    steps {
                        // Add Snyk scan commands here
                        sh 'snyk test'
                    }
                }
                stage('SonarCloud Analysis') {
                    steps {
                        script {
                            // Using SonarQube Scanner
                            def scannerHome = tool 'SonarQubeScanner'
                            withSonarQubeEnv('SonarQubeScanner') {
                                sh "${scannerHome}/bin/sonar-scanner"
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
                        // Build Docker image for advanced users
                        sh 'docker build -t spring-petclinic .'
                    } else {
                        // Use Maven for freshers to create JAR/WAR
                        sh 'mvn clean package'
                    }
                }
            }
        }

        stage('AWS Configuration Check') {
            steps {
                // Validate AWS credentials by listing S3 buckets
                sh 'aws s3 ls'
            }
        }

        stage('Publish Artifacts') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
                        // Push Docker image to Artifactory/Docker Hub
                        sh 'docker tag spring-petclinic:latest your-repo/spring-petclinic:latest'
                        sh 'docker push your-repo/spring-petclinic:latest'
                    } else {
                        // Upload JAR/WAR to Artifactory/S3
                        sh 'jfrog rt u target/*.jar repo/path'
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
