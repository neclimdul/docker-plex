#!/usr/bin/env bash

SCRIPT_LOCATION=$(realpath $(dirname $0))
BASE=$(realpath "${SCRIPT_LOCATION}/..")
docker build --pull --rm -t neclimdul/docker-plex:plex "${BASE}/Plex"
docker build --pull --rm -t neclimdul/docker-plex:plex-pass "${BASE}/PlexPass"
