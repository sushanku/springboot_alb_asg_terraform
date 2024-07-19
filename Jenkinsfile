pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'spring-petclinic:${BUILD_NUMBER}'
    }
    
    stages {        
        stage('Run Tests') {
            steps {
                sh"""
                cd $WORKSPACE/spring-petclinic
                sh './gradlew test'
                """
            }
        }
        
        stage('Run Linter') {
            steps {
                sh"""
                cd $WORKSPACE/spring-petclinic
                sh './gradlew check'
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
                    sh "trivy image ${DOCKER_IMAGE}"
            }
        }
        
        // Additional stages for pushing to ECR and deploying to EC2...
    }
    
    // post {
    //     always {
    //         // Clean up Docker images
    //         // sh "docker rmi ${DOCKER_IMAGE} || true"
    //     }
    // }
}