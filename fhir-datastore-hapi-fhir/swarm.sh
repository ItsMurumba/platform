#!/bin/bash

composeFilePath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

if [ "$1" == "init" ]; then
    if  [ "$2" == "dev" ]; then
        docker stack deploy -c "$composeFilePath"/docker-compose-postgres.yml -c "$composeFilePath"/docker-compose-postgres.dev.yml instant

        echo "Sleep 60 seconds to give Postgres time to start up before HAPI-FHIR"
        sleep 60

        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.dev.yml instant
    else
        docker stack deploy -c "$composeFilePath"/docker-compose-postgres.yml -c "$composeFilePath"/docker-compose-postgres.cluster.yml instant

        echo "Sleep 60 seconds to give Postgres time to start up before HAPI-FHIR"
        sleep 60

        docker stack deploy -c "$composeFilePath"/docker-compose.yml instant
    fi
elif [ "$1" == "up" ]; then
    if [ "$2" == "dev" ]; then
        docker stack deploy -c "$composeFilePath"/docker-compose-postgres.yml -c "$composeFilePath"/docker-compose-postgres.dev.yml instant
        sleep 20
        docker stack deploy -c "$composeFilePath"/docker-compose.yml -c "$composeFilePath"/docker-compose.dev.yml instant
    else
        docker stack deploy -c "$composeFilePath"/docker-compose-postgres.yml -c "$composeFilePath"/docker-compose-postgres.cluster.yml instant
        sleep 20
        docker stack deploy -c "$composeFilePath"/docker-compose.yml instant
    fi 
elif [ "$1" == "down" ]; then
    docker service scale instant_hapi-fhir=0 instant_postgres-1=0 instant_postgres-2=0 instant_postgres-3=0
elif [ "$1" == "destroy" ]; then
    docker service rm instant_hapi-fhir instant_postgres-1 instant_postgres-2 instant_postgres-3

    echo "Sleep 10 Seconds to allow services to shut down before deleting volumes"
    sleep 10

    docker volume rm hapi-postgres1 hapi-postgres2 hapi-postgres3
else
    echo "Valid options are: init, up, down, or destroy"
fi
