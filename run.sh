#!/bin/bash
# Script intended for running/testing docker images built with the build.sh script
# Does not include db container
VOLUME="$(pwd)/resources:/home/wp/resources"
IMAGE="wp-dev-env:latest"
PORTS="-p 8080:80 -p 8000:8000"
docker run --rm -it -v $VOLUME $PORTS $IMAGE /bin/bash
