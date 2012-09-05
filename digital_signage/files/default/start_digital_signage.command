#! /bin/bash

launchctl load /Library/LaunchDaemons/edu.biola.digsig.plist
launchctl load /Library/LaunchDaemons/edu.biola.killDigitalSignage.plist

sleep 15

osascript -e "ignoring application responses" -e "tell application \"Terminal\" to quit" -e "end ignoring"
