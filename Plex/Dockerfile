FROM ubuntu:16.04
MAINTAINER James Gilliland <neclimdul@gmail.com>

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm" \
    RUN_AS_ROOT="true" \
    CHANGE_DIR_RIGHTS="false" \
    CHANGE_CONFIG_DIR_OWNERSHIP="true" \
    HOME="/config" \
    PLEX_DISABLE_SECURITY=1 \
    PLEX_URL="https://plex.tv/api/downloads/1.json"

VOLUME ["/config","/data"]
EXPOSE 32400
CMD ["/start.sh"]

ADD install.sh /install.sh

RUN buildDeps="jq wget" \
  && echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup \
  && echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache \
  && apt-get -q update \
  && apt-get -qy dist-upgrade \
  && apt-get install -qy \
    iproute2 \
    ca-certificates \
    openssl \
    xmlstarlet \
    curl \
  && apt-get install -qy $buildDeps \
  && sh /install.sh \
  && apt-get purge -qy $buildDeps \
  && apt-get -y autoremove \
  && apt-get -y clean \
  && rm -rf /var/lib/apt/lists/* \
  rm -rf /tmp/*

ADD Preferences.xml /Preferences.xml
ADD start.sh /start.sh
