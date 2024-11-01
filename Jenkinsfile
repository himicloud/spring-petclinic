pipeline {
    agent any

    environment {
        PACKER_FILE = '**aws-ami-v1.pkr.hcl**'  // Confirm this is the correct Packer file name
        REPO_URL = 'https://github.com/himicloud/spring-petclinic.git'
        REPO_DIR = '**ansible**'  // Confirm this is the correct directory name for cloning
        SONAR_TOKEN = credentials('**sonar_token**')  // Ensure SonarCloud token is saved with this ID
    }

    tools {
        sonar '**SonarQubeScanner**' // Name must match the SonarQube Scanner configured in Global Tool Configuration
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
                        credentialsId: '**aws_credential**',  // Verify this ID for AWS credentials
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
                        credentialsId: '**aws_credential**',  // Confirm AWS credentials ID
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
                    def scannerHome = tool '**SonarQubeScanner**' // Verify the SonarQubeScanner name
                    withSonarQubeEnv('SonarCloud') {
                        sh "${scannerHome}/bin/sonar-scanner -Dsonar.organization='**himicloud**' -Dsonar.projectKey='**himicloud_spring-petclinic**' -Dsonar.login=${SONAR_TOKEN}"
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
