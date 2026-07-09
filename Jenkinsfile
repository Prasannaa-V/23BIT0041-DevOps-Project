pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds') // Jenkins credential ID
        DOCKER_IMAGE = "Prasannaa-V/abc-technologies-website"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        KUBECONFIG_CRED = credentials('kubeconfig') // Jenkins secret file credential ID
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Cloning repository from GitHub...'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t $DOCKER_IMAGE:$IMAGE_TAG -t $DOCKER_IMAGE:latest .'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Logging in and pushing image to Docker Hub...'
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh 'docker push $DOCKER_IMAGE:$IMAGE_TAG'
                sh 'docker push $DOCKER_IMAGE:latest'
                sh 'docker logout'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes cluster...'
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh 'kubectl apply -f k8s/deployment.yaml'
                    sh 'kubectl apply -f k8s/service.yaml'
                    sh 'kubectl set image deployment/abc-website abc-website=$DOCKER_IMAGE:$IMAGE_TAG'
                    sh 'kubectl rollout status deployment/abc-website'
                }
            }
        }

        stage('Verify Rollout') {
            steps {
                sh 'kubectl get pods -l app=abc-website'
                sh 'kubectl get svc abc-website-service'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully. Website deployed.'
        }
        failure {
            echo 'Pipeline failed. Check console output above.'
        }
    }
}
