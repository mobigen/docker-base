FROM ubuntu:22.04

LABEL maintainer="Mobigen (irisdev@mobigen.com)"
LABEL name="Python Base Image"
LABEL version="3.10.4"

ARG UNAME=iris
ARG UID=1000
ARG GID=3000
ARG HOME=/app

ENV HOME $HOME
ENV USER_NAME $UNAME
ENV USER_UID $UID
ENV USER_GID $GID

RUN set -x \
    && addgroup --gid $GID --system $UNAME \
    && adduser --system --disabled-password --no-create-home --uid $UID --home $HOME --shell /sbin/nologin --ingroup $UNAME --gecos $UNAME $UNAME

RUN apt update -y \
    && apt install -y python3.10 python3-pip \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $HOME
