FROM python:3.9.12-alpine3.15

LABEL maintainer="Mobigen"
LABEL name="Python Base Image"
LABEL version="3.9.12"

ARG UNAME=iris
ARG UID=1000
ARG GID=3000
ARG HOME=/app

ENV HOME $HOME
ENV USER_NAME $UNAME
ENV USER_UID $UID
ENV USER_GID $GID

RUN set -x \
    && addgroup -g $GID -S $UNAME \
    && adduser -S -D -H -u $UID -h $HOME -s /sbin/nologin -G $UNAME -g $UNAME $UNAME

WORKDIR $HOME
