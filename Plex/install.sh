#!/bin/sh

PLEX_JSON=$(curl -s $PLEX_URL | jq -r '.computer.Linux.releases[] | select(.build=="linux-x86_64" and .distro=="debian") | .')
PLEX_DOWNLOAD=$(echo $PLEX_JSON | jq -r '.url')
PLEX_CHECKSUM=$(echo $PLEX_JSON | jq -r '.checksum')

wget -q -O plex_server.deb $PLEX_DOWNLOAD && \
  echo "$PLEX_CHECKSUM *plex_server.deb" | sha1sum -c - && \
  dpkg -i plex_server.deb && \
  rm plex_server.deb
exit $?
