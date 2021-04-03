#!/bin/bash

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKGROUND_DIR="/usr/share/backgrounds"
PROPERTIES_DIR="/usr/share/gnome-background-properties"

cp -r $REPO_DIR/fluent $BACKGROUND_DIR
cp -r $REPO_DIR/gnome-background-properties/fluent.xml $PROPERTIES_DIR
