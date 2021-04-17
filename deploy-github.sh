#!/bin/bash
set -e

env=$1
project=$2
timestamp=`date "+%Y-%m-%d %H:%M:%S"`

if [ $# -ne 1 ]
  then
    echo "Please input 1 argument. Ex. sh deploy {project}"
    exit 1
fi

if [ $1 != "toliman" ]
  then
    echo "project does not exist"
    exit 1
fi

echo ====================================================================================
echo project: $1
echo ====================================================================================

echo deploy web to github...
cd ../$1
git checkout master
git pull
npm run pre:deploy
npm run deploy
echo ====================================================================================
