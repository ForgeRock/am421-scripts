#!/bin/bash
# AM421 script to check-out the state
# checkout-state.sh
# Parameters
#  1. state to be checked out: lab01 ... lab12
# 2016-2018. VRG
# 2018.05. Pal
# 2018.11 VRG
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
GIT_SOURCES_DIR="git@github.com:ForgeRock"

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

function checkout_repository_state {
    local REPO_NAME="$1"
    local BRANCH="$2"
    local DEPLOY_AS_AM_EXTENSION=$3
    local REPO_SOURCE_GIT="${GIT_SOURCES_DIR}/${REPO_NAME}.git"
    REPO_NAME=${REPO_NAME/am421-/}  # strip leading am421- text from repo name from here on
    local REPO_TARGET_DIR="${PROJECTS_DIR}/${REPO_NAME}"

    if ! [[ "$REPO_NAME" =~ ^[a-z0-9-]{1,}$ ]]
    then
        log "Unsafe git repo name: {$REPO_NAME}"
        exit 1
    fi

    if [ ! "$BRANCH" = "N/A" ]
    then
        log "Putting project $(tput bold)${REPO_NAME}$(tput sgr0) into state $(tput bold)${BRANCH}$(tput sgr0)..."
        logf "  Deleting project dir..."
        rm -rf "$REPO_TARGET_DIR"
        logstatus
        #logf "  Fetching latest version of git repository..."
        #git --git-dir "${REPO_SOURCE_GIT}" fetch --all > /dev/null
        #logstatus
        logf "  Cloning ${REPO_NAME} repo's branch ${BRANCH}..."
        git clone -q -b "${BRANCH}" "${REPO_SOURCE_GIT}" "${REPO_TARGET_DIR}" > /dev/null
        logstatus

        if [[ $DEPLOY_AS_AM_EXTENSION = true ]]
        then
            build_project "${REPO_NAME}"
            local JAR_PATH=$(find ${REPO_TARGET_DIR}/target -name "${REPO_NAME}*.jar")
            "${SCRIPT_DIR}/deploy_am_extension.sh" --no-tomcat-restart ${JAR_PATH}
        fi

    else
        logf "Removing project $(tput bold)${REPO_NAME}$(tput sgr0)..."
        rm -rf "$REPO_TARGET_DIR"
        logstatus
        if [[ $DEPLOY_AS_AM_EXTENSION = true ]]
        then
            "${SCRIPT_DIR}/undeploy_am_extension.sh" --no-tomcat-restart ${REPO_NAME}
        fi
    fi
}

function checkout_tomcats_state {
    local BRANCH="$1"
    logf "Setting $(tput bold)tomcats$(tput sgr0) folder to state $(tput bold)${BRANCH}$(tput sgr0)..."
    cd "${TOMCATS_HOME}"
    git fetch --all > /dev/null
    git checkout -q -f "${BRANCH}"
    local CHECKOUT_STATUS=$?
    git reset -q --hard "origin/${BRANCH}"
    logstatus
    return $CHECKOUT_STATUS
}

function replace_am_state {
    local STATE="$1"
    local AM_BACKUP="${AM_BACKUPS_DIR}/${STATE}"

    log "Putting $(tput bold)AM$(tput sgr0) into state $(tput bold)${STATE}$(tput sgr0)..."

    if ! [ -d $AM_BACKUP ]
    then
        log "  Backup not found for state ${STATE}"
        return 1
    fi

    logf "  Deleting current AM config dir..."
    rm -rf $AM_CONFIG_DIR
    logstatus

    logf "  Copying backup of state ${STATE} into place..."
    cp -rp "${AM_BACKUP}" "${AM_CONFIG_DIR}"
    logstatus
    return $?
}

# RESOLVING CONFIG
CONFIG=$(resolve_state_config "$1")

if [ $? -eq 1 ]
then
    exit 1
fi

SELECT_ROLE_NODE_BRANCH=$(read_config_property "select-role-node")
AM_EXTENSIONS_BRANCH=$(read_config_property "am-extensions")
CONTACTLIST_BRANCH=$(read_config_property "contactlist")
TOMCATS_BRANCH=$(read_config_property "tomcats")
AM_BACKUP_NAME=$(read_config_property "am")
SCRIPTED_CLIENT_AUTH_NODE_BRANCH=$(read_config_property "scripted-client-auth-node")


# echo "AM_BACKUP_DIR=$AM_BACKUP_DIR"
# echo "AM_EXTENSIONS_BRANCH=$AM_EXTENSIONS_BRANCH"
# echo "SELECT_ROLE_NODE_BRANCH=$SELECT_ROLE_NODE_BRANCH"
# echo "CONTACTLIST_BRANCH=$CONTACTLIST_BRANCH"
# echo "TOMCATS_BRANCH=$TOMCATS_BRANCH"
# echo "SCRIPTED_CLIENT_AUTH_NODE_BRANCH=$SCRIPTED_CLIENT_AUTH_NODE_BRANCH"


"$SCRIPT_DIR/manage_tomcats.sh" login stop

replace_am_state "${AM_BACKUP_NAME}"
#checkout_tomcats_state ${TOMCATS_BRANCH}
checkout_repository_state "am421-am-extensions" "${AM_EXTENSIONS_BRANCH}" true
checkout_repository_state "am421-select-role-node" "${SELECT_ROLE_NODE_BRANCH}" true
checkout_repository_state "am421-scripted-client-auth-node" "${SCRIPTED_CLIENT_AUTH_NODE_BRANCH}" true

"$SCRIPT_DIR/manage_tomcats.sh" login start

checkout_repository_state "am421-contactlist" "${CONTACTLIST_BRANCH}"
"$SCRIPT_DIR/deploy_contactlist.sh"

echo $1 > ${COURSE_DIR}/STATE