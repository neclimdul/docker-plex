#!/bin/bash
# If debug mode, then enable xtrace
if [ "${DEBUG,,}" = "true" ]; then
  set -x
  echo "RUN_AS_ROOT=${RUN_AS_ROOT}"
  echo "CHANGE_DIR_RIGHTS=${CHANGE_DIR_RIGHTS}"
  echo "CHANGE_CONFIG_DIR_OWNERSHIP=${CHANGE_CONFIG_DIR_OWNERSHIP}"
  echo "PLEX_HOME=${PLEX_HOME}"
  echo "PLEX_DISABLE_SECURITY=${PLEX_DISABLE_SECURITY}"
  echo "PLEX_URL=${PLEX_URL}"
fi
CHANGE_DIR_RIGHTS="true"

# Start time for benchmarks.
start=`date +%s`

# Configurable group name to user for data group management.
PLEX_GROUP=plextmp
DATA_GID=$(stat -c "%g" /data)
CONFIG_UID=$(stat -c "%u" /config)

# Preferences
[ -f /etc/default/plexmediaserver ] && . /etc/default/plexmediaserver
PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR:-${PLEX_HOME}/Library/Application Support}"
PLEX_PREFERENCES="${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/Preferences.xml"
PLEX_PID="${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/plexmediaserver.pid"

# Legacy default?
if [[ -n "${SKIP_CHOWN_CONFIG}" ]]; then
  CHANGE_CONFIG_DIR_OWNERSHIP=false
fi

# Set the group and user plex will run as.
if $RUN_AS_ROOT; then
  SERVICE_USER=root
else
  SERVICE_USER=plex
  usermod -u $CONFIG_UID -d $PLEX_HOME plex
fi

echo "Choose $SERVICE_USER because RUN_AS_ROOT set to $RUN_AS_ROOT"
echo $SERVICE_USER > /etc/container_environment/SERVICE_USER

## Fix up group permissions on data directory.
## Credit:  https://stackoverflow.com/a/28596874/249107
function ensureDataGroup() {
  # Create new group using target GID and add plex user
  local EXISTS=$(grep "${DATA_GID}" /etc/group | wc -l)
  if [ "$EXISTS" = "0" ]; then
    groupadd --gid "${DATA_GID}" "${PLEX_GROUP}"
  else
    # GID exists, find group name and add
    PLEX_GROUP=$(getent group "$DATA_GID" | cut -d: -f1)
  fi

  # Ensure service user is part of the new group.
  usermod -a -G "${PLEX_GROUP}" $SERVICE_USER

  # Change all files in directory to be readable by group
  if [ "${CHANGE_DIR_RIGHTS,,}" = "true" ]; then
    echo "Changing data directory ownership and rights"
     # We don't need the data directory synced to do our other processes so fork it into the backgroup.
    ( find /data ! -group "${PLEX_GROUP}" -print0 | xargs -0 -n 1 -P 3 -I{} chgrp "${PLEX_GROUP}" {} ) &
    ( chmod -R g+rX /data ) &
  fi
}

## Fix up ownership of config directory.
function ensureConfigOwnership() {
  if [ "${CHANGE_CONFIG_DIR_OWNERSHIP,,}" = "true" ]; then
    echo "Changing config directory ownership"
    find /config ! -user ${SERVICE_USER} -print0 | xargs -0 -n 1 -P 3 -I{} chown ${SERVICE_USER}: {}
  fi
}

## Get the value of a preference.
##
## $1 - Preference key
function getPreference() {
  local preference_key="$1"
  xmlstarlet sel -T -t -m "/Preferences" -v "@${preference_key}" -n "${PLEX_PREFERENCES}"
}

## Set the value of a preference.
##
## $1 - Preference key
## $2 - Preference value
function setPreference(){
  local preference_key="$1"
  local preference_val="$2"
  if [ -z "$(getPreference "${preference_key}")" ]; then
    echo "Inserting ${preference_key}: ${preference_val}"
    xmlstarlet ed --inplace --insert "Preferences" --type attr -n "${preference_key}" -v "${preference_val}" "${PLEX_PREFERENCES}"
  else
    echo "Updating ${preference_key}: ${preference_val}"
    xmlstarlet ed --inplace --update "/Preferences[@${preference_key}]" -v "${preference_val}" "${PLEX_PREFERENCES}"
  fi
}

## Set config value.
##
## $1 - Config key
## $2 - Config value
function setConfig(){
  local config_key="$1"
  local config_val="$2"
  if [ -z "$(xmlstarlet sel -T -t -m "/Preferences" -v "@${config_key}" -n /config/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml)" ]; then
    echo "Inserting ${config_key}: ${config_val}"
    xmlstarlet ed --inplace --insert "Preferences" --type attr -n "${config_key}" -v "${config_val}" "/config/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml"
  else
    echo "Updating ${config_key}: ${config_val}"
    xmlstarlet ed --inplace --update "/Preferences[@${config_key}]" -v "${config_val}" "/config/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml"
  fi
}

# Sync groups/users and optionally ensure access.
ensureDataGroup
ensureConfigOwnership

# Setup preferences.
if [ ! -f "${PLEX_PREFERENCES}" ]; then
  echo "Setting up first time files and folders."
  pref_dir=$(dirname "${PLEX_PREFERENCES}")
  mkdir -p "$pref_dir"
  cp /Preferences.xml "${PLEX_PREFERENCES}"
fi

# Set the PlexOnlineToken to PLEX_TOKEN if defined,
# otherwise get plex token if PLEX_USERNAME and PLEX_PASSWORD are defined,
# otherwise account must be manually linked via Plex Media Server in Settings > Server
if [ -n "${PLEX_TOKEN}" ]; then
  setPreference PlexOnlineToken ${PLEX_TOKEN}
elif [ -n "${PLEX_USERNAME}" ] && [ -n "${PLEX_PASSWORD}" ] && [ -n "$(getPreference "PlexOnlineToken")" ]; then
  # Ask Plex.tv a token key
  PLEX_TOKEN=$(curl -u "${PLEX_USERNAME}":"${PLEX_PASSWORD}" 'https://plex.tv/users/sign_in.xml' \
    -X POST -H 'X-Plex-Device-Name: PlexMediaServer' \
    -H 'X-Plex-Provides: server' \
    -H 'X-Plex-Version: 0.9' \
    -H 'X-Plex-Platform-Version: 0.9' \
    -H 'X-Plex-Platform: xcid' \
    -H 'X-Plex-Product: Plex Media Server'\
    -H 'X-Plex-Device: Linux'\
    -H 'X-Plex-Client-Identifier: XXXX' --compressed | sed -n 's/.*<authentication-token>\(.*\)<\/authentication-token>.*/\1/p')
fi

if [ "${PLEX_TOKEN}" ]; then
  setConfig PlexOnlineToken "${PLEX_TOKEN}"
fi

# Tells Plex the external port is not "32400" but something else.
# Useful if you run multiple Plex instances on the same IP
[ -n "${PLEX_EXTERNALPORT}" ] && setPreference ManualPortMappingPort "${PLEX_EXTERNALPORT}"

# Allow disabling the remote security (hidding the Server tab in Settings)
[ -n "${PLEX_DISABLE_SECURITY}" ] && setPreference disableRemoteSecurity "${PLEX_DISABLE_SECURITY}"

# Detect networks and add them to the allowed list of networks
NETWORK_LIST=$(ip route | grep '/' | awk '{print $1}' | paste -sd "," -)
PLEX_ALLOWED_NETWORKS=${PLEX_ALLOWED_NETWORKS:-$NETWORK_LIST}
[ -n "${PLEX_ALLOWED_NETWORKS}" ] && setPreference allowedNetworks "${PLEX_ALLOWED_NETWORKS}"

# Remove previous pid if it exists
rm -f "${PLEX_PID}"

# Wait for backgrounded processes to complete.
for job in `jobs -p`; do wait $job; done

end=`date +%s`
echo $((end-start)) > /config/startup.txt
echo "Benchmarks: $((end-start))"

