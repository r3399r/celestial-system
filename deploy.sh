#!/bin/bash
env=$1
project=$2

if [ $# -ne 2 ]
  then
    echo "Please input 2 arguments. Ex. sh deploy {env} {project}"
    exit 1
fi

if [ $1 != "dev" ] && [ $1 != "prod" ]
  then
    echo "env should be dev or prod"
    exit 1
fi


if [ $2 != "yy-aquarius" ] && 
   [ $2 != "yy-cancer" ]
  then
    echo "project does not exist"
    exit 1
fi

echo ==================================================================================
echo env: $1
echo project: $2
echo ==================================================================================

echo deploy web to s3...
cd ../$2
npm run deploy:$1
echo ==================================================================================

echo deploy lambda...
cd ../yy-zodiac-lambda
npm run deploy:$1
echo ==================================================================================

echo deploy cloudfront...
cd ../yy-zodiac-system
aws cloudformation package --template-file cloudfront-template.yaml --output-template-file packaged.yaml --s3-bucket y-cf-midway
aws cloudformation deploy --template-file packaged.yaml --stack-name $2-$1-stack --parameter-overrides ProjectName=$2 TargetEnvr=$1
