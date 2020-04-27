pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                container('nodejs') {
                    sh "node --version"
                }
                sh 'ls'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}