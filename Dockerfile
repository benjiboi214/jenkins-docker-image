FROM jenkins/jenkins

## Setup AWS S3 Access credentials for config pull
ARG uid=1000
ARG gid=1000
ARG user=jenkins

## Switch to root user to install awscli -- https://github.com/WASdev/ci.docker/issues/194#issuecomment-433519379
USER root

# Install JQ
RUN apt-get update && \
    apt-get install -y jq

## Install AWS CLI cleanly -- https://stackoverflow.com/a/46049066
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        python3-setuptools \
        groff \
        less \
    && pip3 install --upgrade pip \
    && apt-get clean

RUN pip3 --no-cache-dir install --upgrade awscli

## Copy across entry point script
COPY ./entrypoint.sh /entrypoint
RUN sed -i 's/\r$//g' /entrypoint
RUN chmod +x /entrypoint
RUN chown ${user} /entrypoint

## Switch back to jenkins user
USER ${user}

ENTRYPOINT ["/entrypoint"]
