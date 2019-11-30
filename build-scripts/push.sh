export TAG_NAME="0.0.4"  # Should come from CLI params

git push origin $TAG_NAME

docker push 413514076128.dkr.ecr.ap-southeast-2.amazonaws.com/jenkins:latest