#!/usr/bin/env bash

docker build --rm -t neclimdul/docker-plex:plex Plex
docker build --rm -t neclimdul/docker-plex:plex-pass PlexPass
