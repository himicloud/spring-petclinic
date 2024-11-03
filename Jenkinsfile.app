pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/himicloud/spring-petclinic.git'
        SONAR_TOKEN = credentials('sonar_token')
    }

    stages {
        stage("Clone Repository") {
            steps {
                sh "rm -rf spring-petclinic"
                sh "git clone ${REPO_URL} spring-petclinic"
            }
        }

        stage("SonarCloud Analysis") {
            steps {
                script {
                    def scannerHome = tool name: 'SonarQubeScanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                    withSonarQubeEnv('SonarQubeScanner') {
                        sh "${scannerHome}/bin/sonar-scanner -Dsonar.organization='himicloud' -Dsonar.projectKey='himicloud_spring-petclinic' -Dsonar.login=${SONAR_TOKEN}"
                    }
                }
            }
        }

        stage("Build with Maven") {
            steps {
                sh "cd spring-petclinic && mvn clean install" // Produces WAR/JAR files
            }
        }

        stage("Containerize with Docker") {
            steps {
                script {
                    def imageName = "himicloud/spring-petclinic:${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
                    sh "docker build -t ${imageName} spring-petclinic"
                    sh "docker tag ${imageName} himicloud/spring-petclinic:latest" // Tagging based on branch
                }
            }
        }

        stage("Push to JFrog Artifactory") {
            steps {
                // Add Artifactory credentials and configuration here to push WAR/JAR or Docker images.
                echo "Pushing to JFrog Artifactory..."
            }
        }
    }

    post {
        always {
            echo 'Application build and analysis pipeline completed'
        }
    }
}
