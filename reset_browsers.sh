#!/bin/bash
# Reset chrome state

SCRIPT_DIR="$( dirname "$( which "$0" )" )"
source $SCRIPT_DIR/common.sh

logf "Shutting down Google Chrome..."
pkill chrome
logstatus

logf "Shutting down Mozilla Firefox..."
pkill firefox
logstatus

logf "Shutting down Mozilla Seamonkey..."
pkill seamonkey
logstatus

logf "Deleting current Chrome settings and cache..."
rm -rf ~/.config/google-chrome ~/.cache/google-chrome
logstatus

logf "Deleting current Firefox settings and cache..."
rm -rf ~/.mozilla/firefox ~/.cache/mozilla/firefox
logstatus

logf "Deleting current Seamonkey settings and cache..."
rm -rf ~/.mozilla/seamonkey ~/.cache/mozilla/seamonkey
logstatus

logf "Replacing Chrome settings with the initial..."
cd /
tar xjf "${COURSE_DIR}/backups/chrome-settings.tar.bz2"
logstatus

logf "Replacing Firefox settings with the initial..."
cd /
tar xjf "${COURSE_DIR}/backups/firefox-settings.tar.bz2"
logstatus

logf "Replacing Seamonkey settings with the initial..."
cd /
tar xjf "${COURSE_DIR}/backups/seamonkey-settings.tar.bz2"
logstatus


