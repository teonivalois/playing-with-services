#! /bin/bash
# Create playground network and add kong to it
docker network create -d overlay --attachable playground
docker service update --network-add playground kong

docker service rm service1 service2
docker build -f ../service1.dockerfile ../ -t playground/service1
docker build -f ../service2.dockerfile ../ -t playground/service2

# Deploy services
docker service create \
    --name rabbitmq \
    --network playground \
    -e 'RABBITMQ_DEFAULT_USER=playground' \
    -e 'RABBITMQ_DEFAULT_PASS=letsplay' \
    rabbitmq:3.7.7-alpine

docker service create \
    --name service1 \
    --network playground \
    -e 'RabbitMQConnectionString=host=rabbitmq;username=playground;password=letsplay' \
    -e 'ASPNETCORE_ENVIRONMENT=Development' \
    playground/service1

docker service create \
    --name service2 \
    --network playground \
    -e 'RabbitMQConnectionString=host=rabbitmq;username=playground;password=letsplay' \
    -e 'ASPNETCORE_ENVIRONMENT=Development' \
    playground/service2