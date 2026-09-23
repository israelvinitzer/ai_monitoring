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
               sh 'docker build -t ai_monitoring-app:latest .'
               sh 'docker tag ai_monitoring-app:latest registry:5000/ai_monitoring-app:latest'
               sh 'docker push registry:5000/ai_monitoring-app:latest'
            }
        }
        
        stage('Pull') {
            steps {
               sh 'docker pull registry:5000/ai_monitoring-app:latest'
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
               sh 'curl -f http://docker:5000/health || exit 1'
            }
        }
        stage('Cleanup') {
            steps {
               sh 'docker rm -f my-app-container || true'
            }
        }
        
        
    }
}
