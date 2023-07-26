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
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH
ENV CLASS_PATH $JAVA_HOME/lib:$CLASS_PATH

RUN set -x \
    && addgroup --gid $GID --system $UNAME \
    && adduser --system --disabled-password --no-create-home --uid $UID --home $HOME --shell /sbin/nologin --ingroup $UNAME --gecos $UNAME $UNAME

RUN apt update -y \
    && apt install -y python3.10 python3-pip openjdk-11-jre-headless openjdk-11-jdk\
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $HOME
