#! /bin/bash
mydir=`dirname "$0"`

# Create playground network and add kong to it
docker network create -d overlay --attachable playground
docker service update --network-add playground kong

docker service rm service1 service2
docker build -f $mydir/../service1.dockerfile $mydir/../ -t playground/service1:0.1.0
docker build -f $mydir/../service2.dockerfile $mydir/../ -t playground/service2:0.1.0

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
    playground/service1:0.1.0

docker service create \
    --name service2 \
    --network playground \
    -e 'RabbitMQConnectionString=host=rabbitmq;username=playground;password=letsplay' \
    -e 'ASPNETCORE_ENVIRONMENT=Development' \
    playground/service2:0.1.0

docker run --rm \
    --network playground \
    appropriate/curl -i -X POST \
        --url http://kong:8001/services/ \
        --data 'name=service1' \
        --data 'url=http://service1/api'

docker run --rm \
    --network playground \
    appropriate/curl -i -X POST \
        --url http://kong:8001/services/service1/routes \
        --data 'paths[]=/service1'