#!/bin/bash

set -ex

docker pull sushanku/spring-petclinic:v1
docker tag sushanku/spring-petclinic:v1 spring-petclinic
docker run --rm --name petclinic-server -d -p 80:8080 -t spring-petclinic