#!/bin/bash
# Fetches the latest version of the scripts

SCRIPT_DIR="$( dirname "$( which "$0" )" )"
source $SCRIPT_DIR/common.sh

cd "$SCRIPT_DIR"

logf "Fetching latest version of scripts..."
git clean -f -q
git reset --hard --quiet master
git pull -f -q 2>&1 | awk 'BEGIN {CHANGES=0} {if ($0 == "Already up-to-date.") {printf "No changes..."} else if (/\|/) { if (CHANGES == 0) {printf "Updating "$1} else { printf ", "$1}; CHANGES++}} END {if (CHANGES > 0) printf "..."}'
logstatus
