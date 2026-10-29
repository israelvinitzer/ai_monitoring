pipeline {
    agent any
    parameters {
        string(
            name: 'VERSION',
            defaultValue: '1.0.0',
            description: 'Application version in X.Y.Z format'
        )
    }
    stages {
        stage('Validate Version') {
            steps {
                sh '''
                    echo "$VERSION" | grep -Eq '^[0-9]+\\.[0-9]+\\.[0-9]+$' || {
                        echo "VERSION must use X.Y.Z format"
                        exit 1
                    }
                '''
            }
        }
        stage('Test') {
            steps {
               sh 'docker run --rm -v $(pwd):/app -w /app python:3.9-slim sh -c "pip install -r requirements-dev.txt && flake8 . && python -m pytest"'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    script {
                        def scannerHome = tool 'SonarScanner'
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t ai_monitoring-app:${VERSION}-build.${BUILD_NUMBER} .'
                sh 'docker tag ai_monitoring-app:${VERSION}-build.${BUILD_NUMBER} registry:5000/ai_monitoring-app:${VERSION}-build.${BUILD_NUMBER}'
                sh 'docker push registry:5000/ai_monitoring-app:${VERSION}-build.${BUILD_NUMBER}'
            }
        }

        stage('Pull') {
            steps {
                sh 'docker pull registry:5000/ai_monitoring-app:${VERSION}-build.${BUILD_NUMBER}'
            }
        }

        stage('Run') {
            steps {
                sh 'docker rm -f my-app-container || true'
                sh 'docker run -d --name my-app-container -p 5000:5000 registry:5000/ai_monitoring-app:${VERSION}-build.${BUILD_NUMBER}'
            }
        }
        stage('Health Check') {
            steps {
                sh '''
                    for attempt in 1 2 3 4 5; do
                        if curl -fsS http://docker:5000/health; then
                            echo "Application is healthy"
                            exit 0
                        fi

                        echo "Attempt $attempt failed; retrying in 3 seconds..."
                        sleep 3
                    done

                    echo "Application did not become healthy"
                    docker logs my-app-container || true
                    exit 1
                '''
            }
        }
    }
    post {
        always {
            echo 'Cleaning up test container!'
            sh 'docker rm -f my-app-container || true'
        }
    }    
}

