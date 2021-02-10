#!/bin/bash

REPO_DIR=$(cd $(dirname $0) && pwd)
ROOT_UID=0

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com"
else
  DEST_DIR="$HOME/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com"
fi

_install() {
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
}

_restore() {
if [[ -f ${DEST_DIR}/stylesheet.css.back ]]; then
  rm -rf ${DEST_DIR}/stylesheet.css
  mv -n ${REPO_DIR}/stylesheet.css.back ${DEST_DIR}/stylesheet.css
else
  prompt -i "\n stylesheet.css.back not exist!"
  exit 0
fi

echo
echo -e "Done!"

notify-send "Resore to default finished!" "Go to [Dash to Dock Settings] > [Appearance] > [Use built-in theme] and turn it off!" -i face-smile
}

while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    -r|--restore)
      restore="true"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '${1:-}'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [[ "${restore}" == "true" ]]; then
  _restore
else
  _install
fi

