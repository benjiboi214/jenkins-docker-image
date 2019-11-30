export DOCKER_HASH="449487c44a27"
export TAG_NAME="0.0.4"  # Should come from CLI params
export TAG_MESSAGE="Message"  # Should come from CLI params

git tag -a $TAG_NAME -m "$TAG_MESSAGE"

docker tag $DOCKER_HASH 413514076128.dkr.ecr.ap-southeast-2.amazonaws.com/jenkins:$TAG_NAME
docker tag $DOCKER_HASH 413514076128.dkr.ecr.ap-southeast-2.amazonaws.com/jenkins:latest
