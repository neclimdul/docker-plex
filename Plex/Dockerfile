FROM neclimdul/docker-plex:base
MAINTAINER James Gilliland <neclimdul@gmail.com>

RUN echo "deb http://shell.ninthgate.se/packages/debian wheezy main" > /etc/apt/sources.list.d/plexmediaserver.list && \
    apt-get -q update && \
    apt-get install -qy plexmediaserver && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*
