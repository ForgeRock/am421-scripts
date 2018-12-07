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

cd "$SCRIPT_DIR"

logf "  Fetching latest version of scripts..."
git clean -f -q
git reset --hard --quiet master
git pull -f -q
logstatus
