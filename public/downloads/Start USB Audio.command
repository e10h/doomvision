#!/bin/bash
cd -- "$(dirname -- "$0")" || exit 1
./doomvision-usb
status=$?
printf '\nReceiver stopped (status %s). Press Enter to close.\n' "$status"
read -r _
