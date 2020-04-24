#!/usr/bin/env bash

SCRIPT_LOCATION=$(realpath $(dirname $0))
BASE=$(realpath "${SCRIPT_LOCATION}/..")
docker build --rm --pull --no-cache -t neclimdul/docker-plex:plex "${BASE}/Plex"
docker build --rm --pull --no-cache -t neclimdul/docker-plex:plex-pass "${BASE}/PlexPass"
