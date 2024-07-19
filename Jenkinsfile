pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "637423476564"
        AWS_DEFAULT_REGION = "us-east-1" // e.g., us-west-2
        ECR_REPO_NAME = "docker_images"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        DOCKER_IMAGE = "${ECR_REPO_NAME}/spring-petclinic:${IMAGE_TAG}"
        ECR_REGISTRY_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
    }

    stages {        
        stage('Run Tests') {
            steps {
                sh"""
                cd $WORKSPACE/spring-petclinic
                ./gradlew test
                """
            }
        }
        
        stage('Run Linter') {
            steps {
                sh"""
                cd $WORKSPACE/spring-petclinic
                ./gradlew check
                """
            }
        }
        
        stage('Build Docker Image') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sh"""
                    cd $WORKSPACE/spring-petclinic
                    docker build -t "${DOCKER_IMAGE}" .
                """
            }
        }
        
        stage('Scan Docker Image') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                    // Use a tool like Trivy for image scanning
                    sh"""
                    export TRIVY_TIMEOUT=900s
                    trivy image -f json -o results.json ${DOCKER_IMAGE}
                    """
            }
        }
        
        // Additional stages for pushing to ECR and deploying to EC2...
        stage('Push to ECR') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                script {
                    withAWS(credentials: 'aws_creds', region: "${AWS_DEFAULT_REGION}") {
                        sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY_URL}"
                        sh "docker tag ${DOCKER_IMAGE} ${ECR_REGISTRY_URL}/${DOCKER_IMAGE}"
                        sh "docker push ${ECR_REGISTRY_URL}/${DOCKER_IMAGE}"
                    }
                }
            }
        }

    }
    
    // post {
    //     always {
    //         // Clean up Docker images
    //         // sh "docker rmi ${DOCKER_IMAGE} || true"
    //     }
    // }
}