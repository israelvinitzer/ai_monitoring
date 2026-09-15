pipeline {
    agent any

    stages {
        stage('Test') {
            steps {
               sh 'docker run --rm -v $(pwd):/app -w /app python:3.9-slim sh -c "pip install -r requirements.txt && flake8 . && python -m pytest"'
            }
        }
        stage('Build') {
            steps {
               sh 'docker build -t my-app .'
            }
        }
        stage('Run') {
            steps {
               sh 'docker rm -f my-app-container || true'
               sh 'docker run -d --name my-app-container -p 5000:5000 my-app'
            }
        }
        stage('Health Check') {
            steps {
               sh 'curl -f http://localhost:5000/health || exit 1'
            }
        }
    }
}
