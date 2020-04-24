#!/bin/sh

###
# Largely copied from out of the box init script. OK'd by plex team... sort of.
#
###

# Set Crash Reporting identification variables
export PLEX_MEDIA_SERVER_INFO_VENDOR="$(grep ^NAME= /etc/os-release | awk -F= '{print $2}' | tr -d \")"
export PLEX_MEDIA_SERVER_INFO_DEVICE="PC"
export PLEX_MEDIA_SERVER_INFO_MODEL="$(uname -m)"
export PLEX_MEDIA_SERVER_INFO_PLATFORM_VERSION="$(grep ^VERSION= /etc/os-release | awk -F= '{print $2}' | tr -d \")"

# Read configuration variable file if it is present
[ -r /etc/default/plexmediaserver ] && . /etc/default/plexmediaserver

if [ -f /etc/default/locale ]; then
  export LANG="$(cat /etc/default/locale | awk -F '=' '/LANG=/{print $2}' | sed 's/"//g')"
  export LC_ALL="$LANG"
fi

ulimit -s "$PLEX_MEDIA_SERVER_MAX_STACK_SIZE"

export LD_LIBRARY_PATH="${PLEX_MEDIA_SERVER_HOME}/lib"
export TMPDIR="${PLEX_MEDIA_SERVER_TMPDIR}"

# Add sleep - for those who launch with this script
echo "Starting Plex Media Server."
su -m "$PLEX_MEDIA_SERVER_USER" -s /bin/sh -c "exec ${PLEX_MEDIA_SERVER_HOME}/Plex\ Media\ Server"
