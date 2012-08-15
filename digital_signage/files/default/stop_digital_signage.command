#! /bin/bash

launchctl unload /Library/LaunchDaemons/edu.biola.digsig.plist
launchctl unload /Library/LaunchDaemons/edu.biola.killDigitalSignage.plist

sleep 5
osascript -e "ignoring application responses" -e "tell application \"Terminal\" to quit" -e "end ignoring"

