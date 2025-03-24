FROM python:3.12-bullseye
MAINTAINER overbyrn

ARG S6_VER="3.1.2.1"
ARG S6_ARCH="x86_64"

ENV S6_LOGGING 0
ENV S6_KEEP_ENV 1
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

RUN DEBIAN_FRONTEND=noninteractive apt update && \
     apt install -y tar git htop iftop vim tzdata rdfind symlinks detox

WORKDIR /fork

RUN git clone https://github.com/thomas694/bulk-downloader-for-reddit_with-saved-hashes.git /fork

RUN pip install .
RUN pip install praw==7.7.1

RUN apt-get update -y && apt-get install ffmpeg -y

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-${S6_ARCH}.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-${S6_ARCH}.tar.xz

COPY ./etc/ /etc/

RUN mkdir /app
COPY ./app/wrapper.sh /app/wrapper.sh
RUN chmod +x /app/wrapper.sh

RUN mkdir /config
COPY default_config.cfg /app/default_config.cfg
COPY options.yaml.example /app/options.yaml.example

WORKDIR /config

VOLUME /config
VOLUME /downloads

EXPOSE 7634

ENTRYPOINT ["/init"]