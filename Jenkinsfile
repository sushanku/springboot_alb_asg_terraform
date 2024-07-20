pipeline {
    agent any

    parameters { 
        string(name: 'AWS_ACCOUNT_ID', defaultValue: '', description: 'AWS Account ID')
        string(name: 'AWS_DEFAULT_REGION', defaultValue: '', description: 'AWS Account Region')
        string(name: 'ECR_REPO_NAME', defaultValue: '', description: 'ECR Repository for docker images')
    }

    environment {
        DOCKER_BUILDKIT = '1'
        DOCKER_IMAGE_TAG = "${ECR_REPO_NAME}:${env.BUILD_NUMBER}"
        ECR_REPO_URL = "${params.AWS_ACCOUNT_ID}.dkr.ecr.${params.AWS_DEFAULT_REGION}.amazonaws.com"
        ECR_DOCKER_TAG = "${ECR_REPO_URL}/${DOCKER_IMAGE_TAG}"
    }

    stages {        
        stage('Run Tests') {
            steps {
                dir('spring-petclinic') {
                    sh "./gradlew test"
                }
            }
        }
        
        stage('Run Linter') {
            steps {
                dir('spring-petclinic') {
                    sh "./gradlew check"
                }
            }
        }
        
        stage('Build Docker Image') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                dir('spring-petclinic') {
                    sh "docker build -t ${DOCKER_IMAGE_TAG} ."
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
                    trivy image -f json -o results.json ${DOCKER_IMAGE_TAG}
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
                            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URL}
                            docker tag ${DOCKER_IMAGE_TAG} ${ECR_DOCKER_TAG}
                            docker push ${ECR_DOCKER_TAG}
                        """
                    }
                }
            }
        }

        stage('Terraform Infra and Deployment') {
            steps {
                dir('infra'){
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws_creds',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh """
                            echo "aws_account_id  = ${AWS_ACCOUNT_ID}" > terraform.tfvars
                            echo "ecr_repo_url    = ${ECR_REPO_URL}" >> terraform.tfvars
                            echo "ecr_docker_tag  = ${ECR_DOCKER_TAG}" >> terraform.tfvars
                            terraform init
                            terraform plan -var-file="terraform.tfvars" -out=tfplan
                            terraform apply -var-file="terraform.tfvars" -auto-approve tfplan
                        """
                    }
                }
            }
        }

        stage('Upload Terraform State to S3') {
            steps {
                dir('infra'){
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws_creds',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]){
                        sh 'aws s3 cp terraform.tfstate s3://terraform-springboot-app-bucket'
                    }
                }
            }
        }
    }
    post {
        always {
            sh "docker rmi ${DOCKER_IMAGE_TAG} || true"
            cleanWs()
        }
    }

}