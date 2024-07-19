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
# sudo usermod -aG docker $USER

# run docker
sudo docker pull sushanku/spring-petclinic:v1
sudo docker tag sushanku/spring-petclinic:v1 spring-petclinic
sudo docker run --rm --name petclinic-server -d -p 80:8080 -t spring-petclinic

