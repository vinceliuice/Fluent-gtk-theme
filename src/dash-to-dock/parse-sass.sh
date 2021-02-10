#!/bin/bash

if [[ ! "$(command -v sassc)" ]]; then
  echo "'sassc' needs to be installed to generate the CSS."
  exit 1
fi

SASSC_OPT=('-M' '-t' 'expanded')

echo "== Generating the CSS..."
sassc "${SASSC_OPT[@]}" "stylesheet."{scss,css}

echo "== done!"
