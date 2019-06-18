#!/bin/bash
# AM421 script to save AM's state
# checkout-state.sh
# Parameters
#  1. state to be saved
# 2019. VRG
SCRIPT_DIR="$( dirname "$( which "$0" )" )"
source $SCRIPT_DIR/common.sh

STATES_JSON="$SCRIPT_DIR/states.json"

"$SCRIPT_DIR/fetch-tools.sh"

function echo_usage {
    log "Usage: $0 $(tput bold)stateName$(tput sgr0)"
    log "Where valid $(tput bold)stateName$(tput sgr0)s are: $(list_valid_states)"
    exit 1
}

COURSE="AM421"
BACKUPS_DIR="/opt/forgerock/course/backups"
AM_BACKUPS_DIR="$BACKUPS_DIR/am"

LOG_DATETIME=$(date +"%Y%m%d_%H%M%S")

NOW=$(date +"%Y.%m.%d. %H:%M:%S")

cd

function read_state_config {
    local CONFIG_NAME=$1
    cat "${STATES_JSON}" | jq '.["'"$CONFIG_NAME"'"]'
}

function read_config_property {
    local PROPERTY_NAME=$1
    echo "${CONFIG}" | jq --raw-output '.["'"$PROPERTY_NAME"'"]'
}

function list_valid_states {
    local CURRENT_STATE=$(cat ${COURSE_DIR}/STATE)
    echo
    cat "${STATES_JSON}" | jq --raw-output 'keys | join("\n")' | awk -v bold="$(tput bold)" -v norm="$(tput sgr0)" '{printf "    %s", $1; if ($1 == "'${CURRENT_STATE}'") { printf " %s(current)%s", bold, norm}; print ""}'
}

function resolve_state_config {
    local CONFIG_NAME=$1
    local CONFIG=$(read_state_config "${CONFIG_NAME}")
    local CONFIG_TYPE=$(echo "$CONFIG" | jq --raw-output 'type')
    if [ "$CONFIG_TYPE" = 'string' ]
    then
        local RESOLVED_CONFIG_NAME=$(echo "$CONFIG" | jq --raw-output '.')
      log "$CONFIG_NAME = $RESOLVED_CONFIG_NAME"
      resolve_state_config "$RESOLVED_CONFIG_NAME"
    elif [ "$CONFIG_TYPE" = 'null' ]
    then
      log "Unknown state: '$CONFIG_NAME'"
      echo_usage
      exit 1
    else
      echo "$CONFIG"
      TARGET_CONFIG_NAME=CONFIG_NAME
    fi
}

function save_am_state {
    local STATE="$1"
    local AM_BACKUP="${AM_BACKUPS_DIR}/${STATE}"

    log "Saving $(tput bold)AM config dir$(tput sgr0) as state $(tput bold)${STATE}$(tput sgr0)..."

    if [ -d $AM_BACKUP ]
    then
        log "  Deleting existing backup for state ${STATE}..."
        rm -rf "$AM_BACKUP"
        logstatus
    fi

    logf "  Cleaning up AM config dir..."
    rm -rf "$AM_CONFIG_DIR/am/backup/*" "$AM_CONFIG_DIR/am/debug/*" "$AM_CONFIG_DIR/am/logs/*" "$AM_CONFIG_DIR/opends/logs/*"
    logstatus

    logf "  Saving AM's config directory into ${AM_BACKUP} ..."
    cp -rp "${AM_CONFIG_DIR}" "${AM_BACKUP}"
    logstatus
    return $?
}

# RESOLVING CONFIG

CONFIG_NAME="$1"

CONFIG=$(resolve_state_config "$CONFIG_NAME")

if [ $? -eq 1 ]
then
    exit 1
fi

AM_BACKUP_NAME=$(read_config_property "am")

if [ "$AM_BACKUP_NAME" != "$CONFIG_NAME" ]
then
    logf "CONFIG refers to a different AM backup. Config: $CONFIG_NAME  AM Backup: $AM_BACKUP_NAME. Select a state which matches the am state name or fix states.json before performing an AM backup into this state.\n"
    exit 1
fi

"$SCRIPT_DIR/manage_tomcats.sh" login stop

save_am_state "${AM_BACKUP_NAME}"
