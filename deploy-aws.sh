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
   [ $2 != "altarf" ]
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

if [ $1 = "prod" ]
  then
    echo tagging celestial-service...
    cd ../celestial-service
    version=$(node -pe "require('./package.json').version")
    
    if git diff v$version | grep "^diff";
      then
        npm version minor

        git push
        versionNew=$(node -pe "require('./package.json').version")
        git push origin v$versionNew
    fi

    echo ====================================================================================
    echo tagging $2...
    cd ../$2
    version=$(node -pe "require('./package.json').version")
    
    if git diff v$version | grep "^diff";
      then
        npm version minor

        git push
        versionNew=$(node -pe "require('./package.json').version")
        git push origin v$versionNew
    fi
    echo ====================================================================================
fi

echo deploy lambda...
cd ../celestial-service
git checkout master
git pull
npm run pre:deploy
aws cloudformation package --template-file aws/cloudformation/$2-template.yaml --output-template-file packaged.yaml --s3-bucket y-cf-midway
aws cloudformation deploy --template-file packaged.yaml --stack-name celestial-$2-$1-stack --parameter-overrides TargetEnvr=$1 --no-fail-on-empty-changeset
echo ====================================================================================

echo deploy infrastructure...
cd ../celestial-system
git checkout master
git pull
aws cloudformation package --template-file process-template.yaml --output-template-file packaged.yaml --s3-bucket y-cf-midway
aws cloudformation deploy --template-file packaged.yaml --stack-name $2-$1-stack --parameter-overrides ProjectName=$2 TargetEnvr=$1 HostName=$host --no-fail-on-empty-changeset
echo ====================================================================================

echo deploy web to s3...
cd ../$2
git checkout master
git pull
npm run pre:deploy
aws s3 sync ./dist s3://$2-$1 --delete --cache-control no-cache
echo ====================================================================================
