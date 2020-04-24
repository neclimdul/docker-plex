#!/bin/sh

PLEX_URL="https://plex.tv/api/downloads/5.json"
PLEX_PASS_URL="https://nerdpalace.net/plexpass.json"

SCRIPT_LOCATION=$(realpath $(dirname $0))
BASE=$(realpath "${SCRIPT_LOCATION}/..")

sed -e "s#\${PLEX_URL}#$PLEX_URL#" "${BASE}/base/template.dockerfile" > "${BASE}/Plex/Dockerfile"
sed -e "s#\${PLEX_URL}#$PLEX_PASS_URL#" "${BASE}/base/template.dockerfile" > "${BASE}/PlexPass/Dockerfile"

for i in "${BASE}/Plex" "${BASE}/PlexPass"; do
	cp "${BASE}/base/install.sh" $i
	cp "${BASE}/base/start.sh" $i
	cp "${BASE}/base/Preferences.xml" $i
	rm -f $i/cont-init.d/*
	cp -a "${BASE}/base/cont-init.d" $i
	rm -f $i/fix-attrs.d/*
	cp -a "${BASE}/base/fix-attrs.d" $i
done
