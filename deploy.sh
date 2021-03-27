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

if [ $2 = "sadalsuud" ];
  then
    host="lucky-star-trip.net"
fi

echo ====================================================================================
echo env: $1
echo project: $2
echo ====================================================================================

echo deploy lambda...
cd ../celestial-service
npm run pre:deploy
aws cloudformation package --template-file aws/cloudformation/template.yaml --output-template-file packaged.yaml --s3-bucket y-cf-midway
aws cloudformation deploy --template-file packaged.yaml --stack-name celestial-service-$1-stack --parameter-overrides TargetEnvr=$1 --no-fail-on-empty-changeset
echo ====================================================================================

echo deploy infrastructure...
cd ../celestial-system
aws cloudformation package --template-file process-template.yaml --output-template-file packaged.yaml --s3-bucket y-cf-midway
aws cloudformation deploy --template-file packaged.yaml --stack-name $2-$1-stack --parameter-overrides ProjectName=$2 TargetEnvr=$1 HostName=$host --no-fail-on-empty-changeset
echo ====================================================================================

echo deploy web to s3...
cd ../$2
npm run pre:deploy
aws s3 sync ./dist s3://$2-$1 --delete --cache-control max-age=0
echo ====================================================================================
