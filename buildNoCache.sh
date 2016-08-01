#!/usr/bin/env bash
docker build --rm --pull --no-cache -t neclimdul/docker-plex:base Base
docker build --rm --pull --no-cache -t neclimdul/docker-plex:plex Plex
docker build --rm --pull --no-cache -t neclimdul/docker-plex:plex-pass PlexPass
