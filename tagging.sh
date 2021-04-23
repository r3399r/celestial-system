#!/bin/bash
set -e

env=$1
project=$2

if [ $# -ne 2 ]
  then
    echo "Please input 2 arguments. Ex. sh deploy {env} {project}"
    exit 1
fi

if [ $1 != "dev" ] && [ $1 != "test" ] && [ $1 != "prod" ]
  then
    echo "env should be dev, test or prod"
    exit 1
fi

if [ $2 != "sadalsuud" ] && 
   [ $2 != "altarf" ] && 
   [ $2 != "toliman"]
  then
    echo "project does not exist"
    exit 1
fi

cd ../celestial-service
version=$(node -pe "require('./package.json').version")
git checkout master
git pull
if git diff v$version | grep "^diff";
  then
    npm version minor

    version2=$(node -pe "require('./package.json').version")
    git push origin v$version2
fi