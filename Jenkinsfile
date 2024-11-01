pipeline {
    agent any

    environment {
        PACKER_FILE = 'aws-ami-v1.pkr.hcl'
        REPO_URL = 'https://github.com/himicloud/spring-petclinic.git'
        REPO_DIR = 'ansible'
        SONAR_TOKEN = credentials('sonar_token')
    }

    stages {
        stage("Clone Repository") {
            steps {
                sh "rm -rf ${REPO_DIR}"
                sh "git clone ${REPO_URL} ${REPO_DIR}"
            }
        }

        stage("AWS Demo") {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws_credential',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    sh "aws s3 ls"
                }
            }
        }

        stage("Building AMI") {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws_credential',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    sh "cd ${REPO_DIR} && packer init ${PACKER_FILE}"
                    sh "cd ${REPO_DIR} && packer build ${PACKER_FILE}"
                }
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
    }

    post {
        always {
            echo 'Pipeline completed'
        }
    }
}
