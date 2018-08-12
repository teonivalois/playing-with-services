#! /bin/bash
mydir=`dirname "$0"`

# Create the swarm (okay to fail if already available)
docker swarm init

# Create Networks
docker network create -d overlay --attachable admin

# (Re)Create Volumes
docker volume rm portainer_data kong_data konga_data
docker volume create portainer_data
docker volume create kong_data
docker volume create konga_data

# Build HAProxy custom image
docker build -f $mydir/../haproxy.dockerfile $mydir/../ -t mycloud/haproxy:0.1.0

# Deploy Databases
docker service create \
    --name kong-database \
    --network admin \
    --mount 'type=volume,src=kong_data,dst=/data' \
    -e 'POSTGRES_USER=kong' \
    -e 'POSTGRES_DB=kong' \
    -e 'POSTGRES_DB=kong' \
    -e 'PGDATA=/data' \
    postgres:10

docker service create \
    --name konga-database \
    --network admin \
    --mount 'type=volume,src=konga_data,dst=/data' \
    -e 'POSTGRES_USER=konga' \
    -e 'POSTGRES_DB=konga' \
    -e 'POSTGRES_DB=konga' \
    -e 'PGDATA=/data' \
    postgres:10

# Deploy Services
docker service create \
    --name portainer \
    --network admin \
    --replicas=1 \
    --constraint 'node.role == manager' \
    --mount 'type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock' \
    --mount 'type=volume,src=portainer_data,dst=/data' \
    portainer/portainer:1.19.1 -H unix:///var/run/docker.sock

docker run --rm \
    --name kong-migrations \
    --network admin \
    --link kong-database:kong-database \
    -e 'KONG_DATABASE=postgres' \
    -e 'KONG_PG_HOST=kong-database' \
    -e 'KONG_PG_USER=kong' \
    -e 'KONG_PG_PASSWORD=kong' \
    -e 'KONG_PG_DATABASE=kong' \
    kong:0.14.0 kong migrations up

docker service create \
    --name kong \
    --network admin \
    -e 'KONG_DATABASE=postgres' \
    -e 'KONG_PG_HOST=kong-database' \
    -e 'KONG_PG_USER=kong' \
    -e 'KONG_PG_PASSWORD=kong' \
    -e 'KONG_PG_DATABASE=kong' \
    -e 'KONG_PROXY_ACCESS_LOG=/dev/stdout' \
    -e 'KONG_ADMIN_ACCESS_LOG=/dev/stdout' \
    -e 'KONG_PROXY_ERROR_LOG=/dev/stderr' \
    -e 'KONG_ADMIN_ERROR_LOG=/dev/stderr' \
    -e 'KONG_ADMIN_LISTEN=0.0.0.0:8001' \
    -e 'KONG_ADMIN_LISTEN_SSL=0.0.0.0:8444' \
    -e 'KONG_PROXY_LISTEN=0.0.0.0:8000' \
    -e 'KONG_PROXY_LISTEN_SSL=0.0.0.0:8443' \
    kong:0.14.0

docker run --rm \
    --network admin \
    pantsel/konga:0.12.0 -c prepare -a postgres -u konga:konga@konga-database/konga

docker service create \
    --name konga \
    --network admin \
    -e 'DB_ADAPTER=postgres' \
    -e 'DB_HOST=konga-database' \
    -e 'DB_PORT=5432' \
    -e 'DB_USER=konga' \
    -e 'DB_PASSWORD=konga' \
    -e 'DB_DATABASE=konga' \
    -e 'TOKEN_SECRET=THIS_SHOULD_BE_A_RANDOM_TOKEN' \
    pantsel/konga:0.12.0

docker service create \
    --name haproxy \
    --network admin \
    --publish 80:80 \
    mycloud/haproxy:0.1.0