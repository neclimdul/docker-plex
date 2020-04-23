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

# Default values prior to ingesting and validating contents of /etc/default/plexmediaserver
PlexUser="plex"
PlexHome="/usr/lib/plexmediaserver"
PlexAppSuppDir="/var/lib/plexmediaserver/Library/Application Support"
PlexTempDir="/tmp"
PlexStackSize=3000
PlexPluginProcs=6

# Read configuration variable file if it is present
[ -r /etc/default/plexmediaserver ] && . /etc/default/plexmediaserver

if [ $Running -gt 0 ]; then
  echo "Plex is already running."
  exit 0
fi

if [ -f /etc/default/locale ]; then
  export LANG="$(cat /etc/default/locale | awk -F '=' '/LANG=/{print $2}' | sed 's/"//g')"
  export LC_ALL="$LANG"
fi

# Use Read-Writeback approach to handle when variables aren't global.

# Check PLEX_USER
if [ "$PLEX_USER" != "" ]; then
  if [ "$(getent passwd "$PLEX_USER")" != "" ]; then
    PlexUser="$PLEX_USER"
  else
    echo "${0}: No such username: \"$PLEX_USER\". Retaining \"$PlexUser\" as default username."
  fi
fi

# Check PLEX_MEDIA_SERVER_USER (Supersedes PLEX_USER)
if [ "$PLEX_MEDIA_SERVER_USER" != "" ]; then
  if [ "$(getent passwd "$PLEX_MEDIA_SERVER_USER")" != "" ]; then
    PlexUser="$PLEX_MEDIA_SERVER_USER"
  else
    echo "${0}: No such username: \"$PLEX_MEDIA_SERVER_USER\".  Retaining \"$PlexUser\" as default username."
  fi
fi

# Prevent "UNKNOWN" when in IPA/LDAP environments  (revert to default)
if [ "$PlexUser" = "UNKNOWN" ]; then
  echo "${0}: Illegal username:  'UNKNOWN'.  Retaining \"plex\" as username."
  PlexUser="plex"
fi

# PlexUser's HOME directory is the default location. Supersede if specified
PlexAppSuppDir="$(getent passwd "$PlexUser" | awk -F: '{print $6}')/Library/Application Support"

# If user specified AppSuppDir, it must already exist.  This overrides the $PlexUser's "$HOME"
if [ "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR" != "" ]; then
  if [ -d "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR" ]; then
    PlexAppSuppDir="$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR"
  else
    echo "${0}: Given Application Support Directory \"$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR\" does not exist.  Ignoring."
  fi
fi

# Check TempDir
Candidate=""
if [ "$PLEX_MEDIA_SERVER_TMPDIR" != "" ]; then
  Candidate="$PLEX_MEDIA_SERVER_TMPDIR"

# Be generous with TEMP DIR specification
elif [ "$TMPDIR" != "" ]; then
  Candidate="$TMPDIR"

elif [ "$TEMP" != "" ]; then
  Candidate="$TEMP"
elif [ "$TMP" != "" ] && [ -d "$TMP" ]; then
  Candidate="$TMP"
fi

# Validate TempCandidate
if [ "$Candidate" != "" ]; then
  if [ -d "$Candidate" ]; then
    PlexTempDir="$Candidate"
  else
    echo "${0}: Temp Directory does not exist: \"$Candidate\".  Using default location."
  fi
fi

# Plug-in Procs  (No checking.  PMS handles internally)
if [ "$PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS" != "" ]; then
  Candidate="$(echo $PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS | grep -x -E '[[:digit:]]+')"
  if [ "$Candidate" != "" ]; then
    PlexPluginProcs="$Candidate"
  else
    echo "${0}: Non-numeric Max Plug-in Procs given: \"$PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS\".  Using default value."
  fi
fi

# Stack Size
if [ "$PLEX_MEDIA_SERVER_MAX_STACK_SIZE" != "" ]; then
  Candidate="$(echo $PLEX_MEDIA_SERVER_MAX_STACK_SIZE | grep -x -E '[[:digit:]]+')"
  if [ "$Candidate" != "" ]; then
    PlexStackSize="$Candidate"
  else
    echo "${0}: Non-numeric Max Stack Size given: \"$PLEX_MEDIA_SERVER_MAX_STACK_SIZE\".  Using default value."
  fi
fi

# Verify Plex Media Server is indeed where it says it is
if [ "$PLEX_MEDIA_SERVER_HOME" != "" ]; then
  if [ -d "$PLEX_MEDIA_SERVER_HOME" ]; then
    PlexHome="$PLEX_MEDIA_SERVER_HOME"
  else
    echo "${0}: Given application location \"${PLEX_MEDIA_SERVER_HOME}\" does not exist.  Using default location."
  fi
fi

# Create AppSuppDir if not present and set ownership
if [ ! -d "$PlexAppSuppDir" ]; then
  mkdir -p "$PlexAppSuppDir"
  if [ $? -eq 0 ]; then
    chown "${PlexUser}"."${PlexUser}" "$PlexAppSuppDir"
  else
    echo "ERROR: Could not create \"$PlexAppSuppDir\".  System error code $?"
    exit 1
  fi
fi

# Build the final runtime environment variables.  Specify these parameters in /etc/default/plexmediaserver
export PLEX_MEDIA_SERVER_USER="$PlexUser"
export PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="$PlexPluginProcs"
export PLEX_MEDIA_SERVER_HOME="$PlexHome"
export PLEX_MEDIA_SERVER_MAX_STACK_SIZE="$PlexStackSize"
export PLEX_MEDIA_SERVER_TMPDIR="$PlexTempDir"
export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="$PlexAppSuppDir"

export LD_LIBRARY_PATH="${PLEX_MEDIA_SERVER_HOME}/lib"
export TMPDIR="${PLEX_MEDIA_SERVER_TMPDIR}"
ulimit -s "$PLEX_MEDIA_SERVER_MAX_STACK_SIZE"

# Add sleep - for those who launch with this script
echo "Starting Plex Media Server."

su -m "$PLEX_MEDIA_SERVER_USER" -s /bin/sh -c "exec ${PLEX_MEDIA_SERVER_HOME}/Plex\ Media\ Server"
