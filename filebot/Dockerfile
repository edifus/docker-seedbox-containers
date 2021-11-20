FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

# set version label
LABEL maintainer="edifus"

# environment variables
ENV HOME /config
ENV LANG C.UTF-8

# install filebot
RUN set -eux && \
  echo '**** install dependencies' && \
  apt-get update && \
  apt-get install -y default-jre-headless \
    libjna-java \
    mediainfo \
    libchromaprint-tools \
    unrar \
    p7zip-full \
    p7zip-rar \
    xz-utils \
    mkvtoolnix \
    atomicparsley \
    sudo \
    gnupg \
    curl \
    file \
    inotify-tools && \
  echo '**** install filebot' && \
  apt-key adv --fetch-keys https://raw.githubusercontent.com/filebot/plugins/master/gpg/maintainer.pub && \
  echo "deb [arch=all] https://get.filebot.net/deb/ universal main" > /etc/apt/sources.list.d/filebot.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends filebot && \
  rm -rvf /var/lib/apt/lists/* && \
  echo '**** apply custom application configuration' && \
  sed -i 's/APP_DATA=.*/APP_DATA="$HOME"/g; s/-Dapplication.deployment=deb/-Dapplication.deployment=docker/g' /usr/bin/filebot

# install watcher scripts
COPY rootfs/ /
