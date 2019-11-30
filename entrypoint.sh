#!/bin/bash

export JENKINS_HOME="/var/jenkins_home"
export AWS_BUCKET_NAME="${AWS_BUCKET_NAME:-"systemiphus-jenkins-config-backups"}"
export AWS_BUCKET_KEY=`aws s3api list-objects --bucket "systemiphus-jenkins-config-backups" |jq  -c ".[] | max_by(.LastModified)|.Key"`
export AWS_BUCKET_KEY="${AWS_BUCKET_KEY%\"}"
export AWS_BUCKET_KEY="${AWS_BUCKET_KEY#\"}"
export AWS_BUCKET_KEY_NO_EXT="${AWS_BUCKET_KEY%.tar.gz}"
export CONFIG_TAR_PATH="$JENKINS_HOME/$AWS_BUCKET_KEY"
# export CONFIG_FOLDER_PATH="$JENKINS_HOME/$AWS_BUCKET_KEY" ## For when the key is the same as the folder that it was created in
export CONFIG_FOLDER_PATH="$JENKINS_HOME/$AWS_BUCKET_KEY_NO_EXT"

## Get tarball from S3 ##
echo "INFO: Getting Config Tarball"
if aws s3api get-object --bucket="$AWS_BUCKET_NAME" --key $AWS_BUCKET_KEY $CONFIG_TAR_PATH; then
    
    ## Unpack tarball ##
    echo "INFO: Got Tarball, Unpacking"
    tar -xvzf $CONFIG_TAR_PATH -C $JENKINS_HOME/
    ls -la $CONFIG_FOLDER_PATH

    ## Put it in the jenkins home dir ##
    echo "INFO: Move config to jenkins dir"
    # Copy global configuration files into the workspace
    cp $CONFIG_FOLDER_PATH/*.xml $JENKINS_HOME/
    # Copy keys and secrets into the workspace
    cp $CONFIG_FOLDER_PATH/identity.key.enc $JENKINS_HOME/
    cp $CONFIG_FOLDER_PATH/secret.key $JENKINS_HOME/
    cp $CONFIG_FOLDER_PATH/secret.key.not-so-secret $JENKINS_HOME/
    cp -r $CONFIG_FOLDER_PATH/secrets $JENKINS_HOME/

    # Copy user configuration files into the workspace
    cp -r $CONFIG_FOLDER_PATH/users $JENKINS_HOME/

    # Copy job definitions into the workspace
    cp -R $CONFIG_FOLDER_PATH/jobs/ $JENKINS_HOME/

    # Copy plugins (I added S3)
    cp -R $CONFIG_FOLDER_PATH/plugins $JENKINS_HOME

    ## Remove tarball and tmp resources ##
    echo "INFO: Remove Tarball and TMP"
    rm -rf $CONFIG_TAR_PATH
    rm -rf $CONFIG_FOLDER_PATH

else

    echo "ERROR: Could not get Tarball"

fi

## Start Jenkins ##
echo "INFO: Start Jenkins!"
exec /sbin/tini -- /usr/local/bin/jenkins.sh "$@"
