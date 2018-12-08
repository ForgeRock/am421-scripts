#!/bin/bash
# AM421 script to clean up just before release

SCRIPT_DIR="$( dirname "$( which "$0" )" )"
source $SCRIPT_DIR/common.sh

$COURSE_VERSION=$(cat "${COURSE_DIR}/VERSION")
$TIMESTAMP = $(date --rfc-3339=seconds)

log "Releasing VM version ${COURSE_VERSION}..."

logf "Are you sure you want to do the cleanup and release the VM? (type $(tput setaf 2)yes$(tput sgr0)). "
read "RESPONSE"

if [ $RESPONSE != 'yes' ]
then
    log "Answer was not 'yes', exiting..."
    exit 1
fi

$SCRIPT_DIR/checkout-state.sh initial

logf "  Setting release timestamp to ${TIMESTAMP}..."
echo $TIMESTAMP > "${COURSE_DIR}/RELEASE_TIMESTAMP"
logsuccess

"$SCRIPT_DIR/reset_browsers.sh"

logf "  Erasing bash history..."
cat /dev/null > ~/.bash_history
logsuccess

logf "  Turning off history for this session..."
history -c
logsuccess

logf "Setting release timestamp to ${TIMESTAMP}..."

