pipeline {
    agent any

    stages {
        stage('Install requirements') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }
        stage('Test') {
            steps {
                sh 'python -m pytest'
            }
        }
    }
}