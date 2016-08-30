FROM neclimdul/docker-plex:base
MAINTAINER James Gilliland <neclimdul@gmail.com>

ENV PLEX_URL="https://plex.tv/api/downloads/1.json"
VOLUME ["/config","/data"]
EXPOSE 32400
CMD ["/start.sh"]

RUN buildDeps="jq wget" && \
  apt-get -q update && apt-get upgrade -yq && \
  apt-get install -qy $buildDeps && \
  sh /install.sh && \
  apt-get purge -qy $buildDeps && \
  apt-get -y autoremove && \
  apt-get -y clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/*
