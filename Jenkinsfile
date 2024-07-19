pipeline {
    agent any

    environment {
        DOCKER_BUILDKIT = '1'
        AWS_ACCOUNT_ID = "637423476564"
        AWS_DEFAULT_REGION = "us-east-1"
        ECR_REPO_NAME = "docker_images"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        DOCKER_IMAGE = "${ECR_REPO_NAME}:${IMAGE_TAG}"
        ECR_REGISTRY_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
    }

    stages {        
        stage('Run Tests') {
            dir('spring-petclinic') {
                steps {
                    sh"""
                    ./gradlew test
                    """
                }
            }
        }
        
        stage('Run Linter') {
            dir('spring-petclinic') {
            steps { 
                    sh"""
                    ./gradlew check
                    """
                }
            }
        }
        
        stage('Build Docker Image') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            dir('spring-petclinic') {
                steps {
                    sh"""
                        docker build -t "${DOCKER_IMAGE}" .
                    """
                }
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
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws_creds',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh """
                            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY_URL}
                            docker tag ${DOCKER_IMAGE} ${ECR_REGISTRY_URL}/${DOCKER_IMAGE}
                            docker push ${ECR_REGISTRY_URL}/${DOCKER_IMAGE}
                        """
                    }
                }
            }
        }

        stage('Terraform Infra and Deployment') {
            dir('infra'){
                steps {
                    script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws_creds',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]])
                        sh """
                            export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
                            export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
                            terraform plan -out=tfplan
                            terraform apply -auto-approve tfplan
                        """
                    }
                }
            }
        }

        stage('Upload Terraform State to S3') {
            dir('infra'){
                steps {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws_creds',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]])
                    script {
                        sh 'aws s3 cp terraform.tfstate s3://terraform-springboot-app-bucket'
                    }
                }
            }
        }
    }
    post {
        always {
            sh "docker rmi ${DOCKER_IMAGE} || true"
            cleanWs()
        }
    }

}