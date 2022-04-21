# Copyright (c) 2022 jblim Mobigen, Inc. All Rights Reserved.

# Build the docker
ARG DOCKER_BUILD_IMAGE=golang:1.18.1-alpine3.15
ARG DOCKER_BASE_IMAGE=alpine:3.15

## Golang Source Build ( In Container Image )
FROM ${DOCKER_BUILD_IMAGE} AS build

## Directory 
WORKDIR /app/
## Source Code Copy To Container
COPY . /app/
## Run Build ( Need Modify[Add] )
#RUN make ... 

## Need Test?
#RUN make test

## Final Product Image
FROM ${DOCKER_BASE_IMAGE}
## Set Image Labels
LABEL name="example" \
  maintainer="irisdev@mobigen.com" \
  vendor="Mobigen" \
  architecture="x86_64" \
  url="https://mobigen.com" \
  description="Example. Created Platform Team Mobigen"

## Image Security(upgrade) And Install Other Package 
RUN \
    apk update \
    && apk upgrade --no-cache \
    && apk --no-cache add \
        tzdata \
    && rm -rf /var/cache/apk/*

RUN cp /usr/share/zoneinfo/Asia/Seoul /etc/localtime

## Set User
ENV USER_UID=1000 \
    USER_NAME=iris \
    USER_GID=3000 \
    GROUP_NAME=mobigen \
    HOME=/app \
    TZ=Asia/Seoul 

## Create/Add User 
COPY --from=build /app/build/user_setup /bin/user_setup
RUN chmod +x /bin/user_setup && /bin/user_setup

## Create Directory
RUN mkdir -p /app/bin /app/configs /app/logs
## Copy File From Build Image To Product Image 
COPY --from=build /app/build/example_binary /app/bin/example_binary

WORKDIR /app

USER ${USER_UID}

EXPOSE 8080

ENTRYPOINT ["/app/bin/example_binary"]
