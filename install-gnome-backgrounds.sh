#!/bin/bash

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKGROUND_DIR="/usr/share/backgrounds"
PROPERTIES_DIR="/usr/share/gnome-background-properties"

for theme in '' '-mountain' '-building'; do
  echo -e "\n Install fluent${theme}... \n"
  rm -rf $BACKGROUND_DIR/fluent${theme}
  cp -r $REPO_DIR/fluent${theme} $BACKGROUND_DIR
  rm -rf $PROPERTIES_DIR/fluent${theme}.xml
  cp -r $REPO_DIR/gnome-background-properties/fluent${theme}.xml $PROPERTIES_DIR
done

echo -e "\n Done! \n"
