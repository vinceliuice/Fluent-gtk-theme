#!/bin/bash

REPO_DIR=$(cd $(dirname $0) && pwd)
ROOT_UID=0

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com"
else
  DEST_DIR="$HOME/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com"
fi

if [[ -f ${DEST_DIR}/stylesheet.css ]]; then
  mv -n ${DEST_DIR}/stylesheet.css ${DEST_DIR}/stylesheet.css.back
  cp -r ${REPO_DIR}/stylesheet.css ${DEST_DIR}/stylesheet.css
else
  prompt -i "\n stylesheet.css not exist!"
  exit 0
fi

echo
echo -e "Done!"

notify-send "All done!" "Go to [Dash to Dock Settings] > [Appearance] > [Use built-in theme] and turn it on!" -i face-smile
