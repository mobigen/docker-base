FROM ubuntu:22.04

# tzdata 설치 시 사용자가 직접 timezone 설정을 할 수 있도록 입력할 수 있는 부분이 나오는데, 도커 이미지를 생성할 때는 입력을 할 수 없으므로 사용자의 입력 없이 넘어가기 위해 설정
ARG DEBIAN_FRONTEND=noninteractive

# tzdata 는 시스템 환경변수 TZ 의 값으로 timezone을 설정하기 때문에 해당 환경 변수를 우리가 원하는 지역으로 설정
ENV TZ=Asia/Seoul

LABEL maintainer="Mobigen (irisdev@mobigen.com)"
LABEL name="Python Base Image"

# ubuntu 에서 버전이 변경 될수 있음으로 새로 빌드시 확인 필요
LABEL version="3.11.4"

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
    && apt install -y software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt install -y python3.11 python3-pip python3.11-dev python3.11-venv python3.11-distutils python3.11-gdbm python3.11-lib2to3 \
    && openjdk-11-jre-headless openjdk-11-jdk \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --config python \
    && update-alternatives --config python3

WORKDIR $HOME
