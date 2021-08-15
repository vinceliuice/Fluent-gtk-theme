#!/bin/bash

INKSCAPE="$(command -v inkscape)" || true
OPTIPNG="$(command -v optipng)" || true
CONVERT="$(command -v convert)" || true

SRC_FILE="wallpapers-times.svg"

for screen in '-1080p' '-2k' '-4k'; do
for theme in '-mountain' '-building'; do
for time in '-morning' '-day' '-night'; do

if [[ "${screen}" == '-1080p' ]]; then
  DPI="96"
elif [[ "${screen}" == '-2k' ]]; then
  DPI="128"
elif [[ "${screen}" == '-4k' ]]; then
  DPI="192"
fi

ASSETS_DIR="wallpaper${screen}"
ASSETS_ID="Fluent${theme}${time}"
PNG_file="$ASSETS_DIR/$ASSETS_ID.png"
JPG_file="$ASSETS_DIR/$ASSETS_ID.jpg"

if [[ -f "$PNG_file" ]]; then
  echo "'$PNG_file' exist! "
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

if [[ -f "$JPG_file" ]]; then
  echo "'$JPG_file' exist! "
else
  echo "Rendering '$JPG_file'"
  "$CONVERT" "$PNG_file" -quality 100 "$ASSETS_DIR/$ASSETS_ID.jpg"
fi

done
done
done
