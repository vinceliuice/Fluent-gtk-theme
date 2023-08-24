#! /bin/bash

INKSCAPE="/usr/bin/inkscape"
OPTIPNG="/usr/bin/optipng"

INDEX="assets.txt"

for window in '' '-square'; do
for color in '' '-Light' '-Dark'; do

ASSETS_DIR="assets${window}${color}"
SRC_FILE="assets${window}${color}.svg"

mkdir -p $ASSETS_DIR

for i in `cat $INDEX`; do
if [ -f $ASSETS_DIR/$i.png ]; then
    echo $ASSETS_DIR/$i.png exists.
else
    echo
    echo Rendering $ASSETS_DIR/$i.png
    $INKSCAPE --export-id=$i \
              --export-id-only \
              --export-filename=$ASSETS_DIR/$i.png $SRC_FILE >/dev/null \
    && $OPTIPNG -o7 --quiet $ASSETS_DIR/$i.png 
fi
done

done
done

exit 0
