pipeline {
    agent { dockerfile true }
    stages {
        stage('Test') {
            steps {
                sh 'hugo version'
                sh 'hugo'
            }
        }
    }
}

