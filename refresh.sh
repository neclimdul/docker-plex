#!/bin/sh

PLEX_URL="https://plex.tv/api/downloads/1.json"
PLEX_PASS_URL="https://nerdpalace.net/plexpass.json"

sed -e "s#\${PLEX_URL}#$PLEX_URL#" Dockerfile.template > Plex/Dockerfile
sed -e "s#\${PLEX_URL}#$PLEX_PASS_URL#" Dockerfile.template > PlexPass/Dockerfile

for i in Plex PlexPass; do
	cp install.sh $i
	cp start.sh $i
	cp Preferences.xml $i
done
#cd Plex && ln -sf ../install.sh && ln -sf ../start.sh && ln -sf ../Preferences.xml && cd -
#cd PlexPass && ln -sf ../install.sh && ln -sf ../start.sh && ln -sf ../Preferences.xml && cd -
