#!/bin/bash
eval "$(aws ecr get-login --no-include-email)"

while getopts ":t:m:" opt; do
  case $opt in
    t) tag="$OPTARG"
    ;;
    m) msg="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

DOCKER_HASH="$(docker build . | tail -c 13)"

git tag -a $tag -m "$msg"
if [ $? -eq 0 ]
then
  :
else
  echo "ERROR: Stopping Script - Could not tag image" >&2
  exit 1
fi

docker tag $DOCKER_HASH 413514076128.dkr.ecr.ap-southeast-2.amazonaws.com/jenkins:$tag
if [ $? -eq 0 ]
then
  :
else
  echo "ERROR: Stopping Script - Docker could not tag image" >&2
  exit 1
fi
docker tag $DOCKER_HASH 413514076128.dkr.ecr.ap-southeast-2.amazonaws.com/jenkins:latest
if [ $? -eq 0 ]
then
  :
else
  echo "ERROR: Stopping Script - Docker could not tag image" >&2
  exit 1
fi

printf "Tagged image %s" "$DOCKER_HASH"
printf " with tag %s" "$tag"
printf " - %s\n" "$msg"

git push origin $tag
docker push 413514076128.dkr.ecr.ap-southeast-2.amazonaws.com/jenkins:$tag
docker push 413514076128.dkr.ecr.ap-southeast-2.amazonaws.com/jenkins:latest

printf "SUCCESS: Pushed tags to git and ecr\n"