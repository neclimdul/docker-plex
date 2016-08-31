FROM neclimdul/docker-plex:base
MAINTAINER James Gilliland <neclimdul@gmail.com>

ENV PLEX_URL="https://nerdpalace.net/plexpass.json"

RUN buildDeps="jq wget" && \
  apt-get -q update && apt-get upgrade -yq && \
  apt-get install -qy $buildDeps && \
  sh /install.sh && \
  apt-get purge -qy $buildDeps && \
  apt-get -y autoremove && \
  apt-get -y clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/*
