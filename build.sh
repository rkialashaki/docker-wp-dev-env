#!/bin/bash
VERSION=`cat ./VERSION`
PROJECT="wp-dev-env"
DOCKERFILE="Dockerfile"
BUILDDIR="."
#VOLUME="./wp-cli:/root/wp-cli"
docker build --pull -t $PROJECT:$VERSION -t $PROJECT:latest \
    -f $DOCKERFILE $BUILDDIR
