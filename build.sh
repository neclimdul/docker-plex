#!/usr/bin/env bash

docker build --pull --rm -t neclimdul/docker-plex:plex Plex
docker build --pull --rm -t neclimdul/docker-plex:plex-pass PlexPass
