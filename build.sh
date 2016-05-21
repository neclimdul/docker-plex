#!/usr/bin/env bash
docker build --rm -t timhaak/plex-base Base
docker build --rm -t timhaak/plex Plex
docker build --rm -t timhaak/plex-pass PlexPass
