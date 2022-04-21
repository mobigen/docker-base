FROM python:3.9.12-alpine3.15

LABEL maintainer="Python Base Image | Platform Team"
LABEL version="3.9.12"

ARG UNAME=iris
ARG UID=1000
ARG GID=3000
ARG HOME=/app

RUN set -x \
    && addgroup -g $GID -S $UNAME \
    && adduser -S -D -H -u $UID -h $HOME -s /sbin/nologin -G $UNAME -g $UNAME $UNAME

USER iris:iris

WORKDIR $HOME
