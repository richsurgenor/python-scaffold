#!/bin/bash


SCAFFOLD_BASE=package_name
PACKAGE_NAME=$1
JENKINS_JOB=${PACKAGE_NAME//_/-}

if [ -z ${PACKAGE_NAME} ]; then
    echo "Usage: $0 <new_package_name>"
    exit 1
fi

mv ${SCAFFOLD_BASE} ${PACKAGE_NAME}
find . -type f -print0 | xargs -0 sed -i "s/${SCAFFOLD_BASE}/${PACKAGE_NAME}/g"
sed -i "s/python-scaffold/${JENKINS_JOB}/g" README.md
