pipeline {
    agent any

    environment {
        BUILD_NO = "${BUILD_NUMBER}"
        IMAGE_NAME = "chaitanya9666/java-web-app"
        DOCKER_SERVICE_NAME = "java-web-app-service"
    }

    stages {

        stage('Download the Code') {
            steps {
                git 'https://github.com/chaithushanvi/java-web-app-docker.git'
            }
        }

        stage('Build the Code (Maven)') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${IMAGE_NAME}:${BUILD_NO} .
                """
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-token', variable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u chaitanya9666 --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                sh """
                    docker push ${IMAGE_NAME}:${BUILD_NO}
                """
            }
        }

        stage('Deploy to Docker Swarm') {
            steps {
                sh """
                    docker service rm ${DOCKER_SERVICE_NAME} || true

                    docker service create \
                      --name ${DOCKER_SERVICE_NAME} \
                      --replicas 2 \
                      --publish published=8081,target=8080 \
                      ${IMAGE_NAME}:${BUILD_NO}
                """
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully"
        }
        failure {
            echo "❌ Pipeline failed"
        }
    }
}
