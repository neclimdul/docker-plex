FROM ubuntu:focal
LABEL maintainer="neclimdul@gmail.com"

VOLUME ["/config","/data"]
EXPOSE 32400
ENTRYPOINT ["/init"]
CMD ["/start.sh"]

HEALTHCHECK --interval=60s --timeout=2s --start-period=120s \
            CMD curl -L 'http://localhost:32400/web/index.html'

# Setup s6 init
ENV S6_VERSION='1.21.8.0'

ENV DEBIAN_FRONTEND="noninteractive" \
    CHANGE_DIR_RIGHTS="false" \
    CHANGE_CONFIG_DIR_OWNERSHIP="true" \
    PLEX_MEDIA_SERVER_USER="plex" \
    PLEX_HOME="/config" \
    PLEX_DISABLE_SECURITY=1 \
    PLEX_URL="${PLEX_URL}"
ENV buildDeps="jq wget"

ADD install.sh /install.sh

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup \
  && apt-get update \
  && apt-get install -qqy \
    iproute2 \
    ca-certificates \
    openssl \
    xmlstarlet \
    curl \
    $buildDeps \
  && wget "https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz" -P /tmp \
  && tar hzxf /tmp/s6-overlay-amd64.tar.gz -C / --exclude=usr/bin/execlineb \
  && tar hzxf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin/execlineb && $_clean \
  && sh /install.sh \
  && apt-get purge -qy $buildDeps \
  && apt-get -y autoremove \
  && apt-get -y clean \
  && rm -rf /var/lib/apt/lists/* \
  rm -rf /tmp/*

ADD cont-init.d/* /etc/cont-init.d/
# ADD fix-attrs.d/* /etc/fix-attrs.d/

ADD Preferences.xml /Preferences.xml

ADD start.sh /
RUN chmod +x /start.sh
