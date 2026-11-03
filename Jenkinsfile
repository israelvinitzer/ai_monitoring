pipeline {
    agent {
        label 'docker-agent'
    }
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
                sh '''
                    test_container="ai-monitoring-test-${BUILD_NUMBER}"

                    docker rm -f "$test_container" >/dev/null 2>&1 || true

                    docker create \
                        --name "$test_container" \
                        --workdir /app \
                        python:3.9-slim \
                        sh -c "pip install -r requirements-dev.txt && flake8 . && python -m pytest"

                    docker cp . "$test_container":/app

                    docker start -a "$test_container"
                '''
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
                    for attempt in 1 2 3 4 5 6 7 8 9 10; do
                        status=$(docker inspect \
                            --format='{{.State.Health.Status}}' \
                            my-app-container)

                        echo "Docker health status: $status"

                        if [ "$status" = "healthy" ]; then
                            echo "Application is healthy"
                            exit 0
                        fi

                        if [ "$status" = "unhealthy" ]; then
                            echo "Application became unhealthy"
                            docker inspect \
                                --format='{{range .State.Health.Log}}{{.Output}}{{end}}' \
                                my-app-container || true
                            docker logs my-app-container || true
                            exit 1
                        fi

                        sleep 3
                    done

                    echo "Application did not become healthy in time"
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
    post {
        always {
            echo 'Cleaning up containers'
            sh 'docker rm -f my-app-container || true'
            sh 'docker rm -f ai-monitoring-test-${BUILD_NUMBER} || true'
        }
    } 
}

