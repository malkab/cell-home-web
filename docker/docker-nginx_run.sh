#!/bin/bash

# Version: 2021-04-07

# -----------------------------------------------------------------
#
# Tests the page.
#
# -----------------------------------------------------------------
#
# Runs an nginx to serve a local site for testing.
#
# -----------------------------------------------------------------
# Check mlkctxt to check. If void, no check will be performed. If NOTNULL,
# any activated context will do, but will fail if no context was activated.
MATCH_MLKCTXT=
# The network to connect to. Remember that when attaching to the network of an
# existing container (using container:name) the HOST is "localhost". Also the
# host network can be connected using just "host". If blank, no network will be
# used.
NETWORK=
# Container identifier root. This is used for both the container name (adding an
# UID to avoid clashing) and the container host name (without UID). Incompatible
# with NETWORK container:name option. If blank, a Docker engine default name
# will be assigned to the container.
ID_ROOT=
# Unique? If true, no container with the same name can be created. Defaults to
# true.
UNIQUE=
# Run mode. Can be PERSISTABLE (-ti), VOLATILE (-ti --rm), or DAEMON (-d). If
# blank, defaults to VOLATILE.
RUN_MODE=
# Container external port. Defaults to 8080.
WWW_PORT=
# Site to serve. Defaults to $(pwd).
SITE_FOLDER=$(pwd)/../
# A set of additional volumes in the form ("source:destination"
# "source:destination"). Defaults to ().
VOLUMES=





# ---

# Check mlkctxt is present at the system
if command -v mlkctxt &> /dev/null ; then

  if ! mlkctxt -c $MATCH_MLKCTXT ; then exit 1 ; fi

fi

# Manage identifier
if [ ! -z "${ID_ROOT}" ] ; then

  N="${ID_ROOT}_$(mlkctxt)"
  CONTAINER_HOST_NAME_F="--hostname ${N}"

  if [ "${UNIQUE}" = false ] ; then

    CONTAINER_NAME_F="--name ${N}_$(uuidgen)"

  else

    CONTAINER_NAME_F="--name ${N}"

  fi

fi

# Network
if [ ! -z "${NETWORK}" ]; then NETWORK="--network=${NETWORK}" ; fi

# Run mode
if [ ! -z "$RUN_MODE" ] ; then

  if [ "$RUN_MODE" = "PERSISTABLE" ] ; then

    COMMAND_DOCKER="docker run -ti"

  elif [ "$RUN_MODE" = "VOLATILE" ] ; then

    COMMAND_DOCKER="docker run -ti --rm"

  elif [ "$RUN_MODE" = "DAEMON" ] ; then

    COMMAND_DOCKER="docker run -d"

  else

    echo Error: unrecognized RUN_MODE $RUN_MODE, exiting...
    exit 1

  fi

else

  COMMAND_DOCKER="docker run -ti --rm"

fi

# Volumes
VOLUMES_F=

if [ ! -z "${VOLUMES}" ] ; then

  for E in "${VOLUMES[@]}" ; do

    VOLUMES_F="${VOLUMES_F} -v ${E} "

  done

fi

# Port
WWW_PORT_F=8080

if [ ! -z "${WWW_PORT}" ]; then WWW_PORT_F=$WWW_PORT ; fi

# Site folder
SITE_FOLDER_F=$(pwd)

if [ ! -z "${SITE_FOLDER}" ]; then SITE_FOLDER_F=$SITE_FOLDER ; fi

# Run
eval $COMMAND_DOCKER \
        $NETWORK \
        $CONTAINER_NAME_F \
        $CONTAINER_HOST_NAME_F \
        -p $WWW_PORT_F:80 \
        -v $SITE_FOLDER_F:/www \
        $VOLUMES_F \
        malkab/nginx-angular:latest
