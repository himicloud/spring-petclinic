stage('Preparation') {
    steps {
        script {
            // Cloning the repository based on the pipeline branch
            checkout([$class: 'GitSCM', branches: [[name: "*/${env.BRANCH_NAME}"]], userRemoteConfigs: [[url: 'https://github.com/himicloud/spring-petclinic.git']]])
        }
    }
}
