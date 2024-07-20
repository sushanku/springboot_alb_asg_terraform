#!/bin/bash

set -ex

# install docker
sudo apt update 
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y


## pull docker image and run the application

# Authenticate Docker to the ECR registry
$(aws ecr get-login-password --region ${aws_region} | sudo docker login --username AWS --password-stdin ${ecr_repo_url})

# Pull the Docker image from ECR
sudo docker pull ${ecr_docker_tag}

# Run the Docker container
sudo docker run -d --name petclinic -p 8080:8080 ${ecr_docker_tag}
