#!/bin/sh

PLEX_URL="https://plex.tv/api/downloads/5.json"
PLEX_PASS_URL="https://nerdpalace.net/plexpass.json"

sed -e "s#\${PLEX_URL}#$PLEX_URL#" Dockerfile.template > Plex/Dockerfile
sed -e "s#\${PLEX_URL}#$PLEX_PASS_URL#" Dockerfile.template > PlexPass/Dockerfile

for i in Plex PlexPass; do
	cp base/install.sh $i
	cp base/plex.sh $i
	cp base/bootstrap.sh $i
	cp base/Preferences.xml $i
done
#cd Plex && ln -sf ../install.sh && ln -sf ../start.sh && ln -sf ../Preferences.xml && cd -
#cd PlexPass && ln -sf ../install.sh && ln -sf ../start.sh && ln -sf ../Preferences.xml && cd -
