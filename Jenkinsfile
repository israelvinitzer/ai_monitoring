pipeline {
    agent any

    stages {
        stage('Test') {
            steps {
               sh 'docker run --rm -v $(pwd):/app -w /app python:3.9-slim sh -c "pip install -r requirements.txt && flake8 . && python -m pytest"'
            }
        }
    }
}
