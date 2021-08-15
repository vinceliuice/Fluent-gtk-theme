#!/bin/bash

INKSCAPE="$(command -v inkscape)" || true
OPTIPNG="$(command -v optipng)" || true

SRC_FILE="wallpapers-flat.svg"

for theme in '-default' '-purple' '-pink' '-red' '-orange' '-yellow' '-green' '-grey' '-light'; do
for screen in '-1080p' '-2k' '-4k'; do
for type in '-flat' '-gradient'; do

if [[ "${screen}" == '-1080p' ]]; then
  DPI="96"
elif [[ "${screen}" == '-2k' ]]; then
  DPI="128"
elif [[ "${screen}" == '-4k' ]]; then
  DPI="192"
fi

ASSETS_DIR="wallpaper${screen}"
ASSETS_ID="wallpaper${theme}${type}"

if [[ -f "$ASSETS_DIR/$ASSETS_ID.png" ]]; then
  echo "'$ASSETS_DIR/$ASSETS_ID.png' exist! "
else
  echo "Rendering '$ASSETS_DIR/$ASSETS_ID.png'"
    "$INKSCAPE" --export-id="$ASSETS_ID" \
                --export-id-only \
                --export-dpi="$DPI" \
                --export-filename="$ASSETS_DIR/$ASSETS_ID.png" "$SRC_FILE" >/dev/null

  if [[ -n "${OPTIPNG}" ]]; then
    "$OPTIPNG" -o7 --quiet "$ASSETS_DIR/$ASSETS_ID.png"
  fi
fi

done
done
done
