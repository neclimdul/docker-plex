#!/usr/bin/env bash
docker build --rm --pull --no-cache -t timhaak/plex:base Base
docker build --rm --pull --no-cache -t timhaak/plex:plex Plex
docker build --rm --pull --no-cache -t timhaak/plex:plex-pass PlexPass
