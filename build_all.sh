#!/bin/bash

set -e -u -o -x pipefail

KUBEKITE_IMAGE_BASE=us.gcr.io/mrt-cicd-i-8c9c/kubekite
TEMPLATES=job-templates/*
REGEX='.*\/(.*)\..*'

# set +u

for TEMPLATE_FILENAME in $TEMPLATES
do
    if [[ $TEMPLATE_FILENAME =~ $REGEX ]]
    then
        TEMPLATE_NAME=${BASH_REMATCH[1]}
        if [[ $TEMPLATE_NAME == "job" ]]
        then
            TAG=$KUBEKITE_IMAGE_BASE:$VERSION
        else
            TAG=$KUBEKITE_IMAGE_BASE:$VERSION-$TEMPLATE_NAME
        fi
        docker build --build-arg JOB_TEMPLATE=$TEMPLATE_FILENAME -t $TAG .
    fi
    docker push $TAG
done
