#!/bin/sh

export HOME=$PLEX_HOME

# Current defaults to run as root while testing.
if [ "${RUN_AS_ROOT}x" = "truex" ]; then
  /usr/sbin/start_pms
else
	su -m -c "/usr/sbin/start_pms" $SERVICE_USER
fi
