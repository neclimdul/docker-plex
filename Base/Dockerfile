FROM ubuntu:16.04
MAINTAINER James Gilliland <neclimdul@gmail.com>

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm"

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup &&\
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    apt-get -q update && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy \
      iproute2 \
      ca-certificates \
      openssl \
      xmlstarlet \
      curl \
      sudo \
    && \
    curl http://shell.ninthgate.se/packages/shell.ninthgate.se.gpg.key | apt-key add - && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

VOLUME ["/config","/data"]

ENV RUN_AS_ROOT="true" \
    CHANGE_DIR_RIGHTS="false" \
    CHANGE_CONFIG_DIR_OWNERSHIP="true" \
    HOME="/config" \
    PLEX_DISABLE_SECURITY=1

EXPOSE 32400

ADD ./Preferences.xml /Preferences.xml
ADD ./start.sh /start.sh

CMD ["/start.sh"]
