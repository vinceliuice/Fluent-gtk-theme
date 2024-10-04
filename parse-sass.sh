#!/bin/bash

if [[ ! "$(command -v sassc)" ]]; then
  echo "'sassc' needs to be installed to generate the CSS."
  exit 1
fi

SASSC_OPT=('-M' '-t' 'expanded')

_COLOR_VARIANTS=('' '-Light' '-Dark')
_SIZE_VARIANTS=('' '-compact')

if [[ -n "${COLOR_VARIANTS:-}" ]]; then
  IFS=', ' read -r -a _COLOR_VARIANTS <<< "${COLOR_VARIANTS:-}"
fi

if [[ -n "${SIZE_VARIANTS:-}" ]]; then
  IFS=', ' read -r -a _SIZE_VARIANTS <<< "${SIZE_VARIANTS:-}"
fi

#  Check command avalibility
function has_command() {
  command -v $1 > /dev/null
}

#  Install needed packages
install_package() {
  if [ ! "$(which sassc 2> /dev/null)" ]; then
    echo sassc needs to be installed to generate the css.
    if has_command zypper; then
      sudo zypper in sassc
    elif has_command apt-get; then
      sudo apt-get install sassc
    elif has_command dnf; then
      sudo dnf install sassc
    elif has_command dnf; then
      sudo dnf install sassc
    elif has_command pacman; then
      sudo pacman -S --noconfirm sassc
    fi
  fi
}

echo "== Generating the CSS..."

install_package

cp -rf src/_sass/_tweaks.scss src/_sass/_tweaks-temp.scss
cp -rf src/gnome-shell/sass/_tweaks.scss src/gnome-shell/sass/_tweaks-temp.scss

if [[ "$(command -v gnome-shell)" ]]; then
  gnome-shell --version
  SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -1)"

  if [[ "${SHELL_VERSION:-}" -ge "45" ]]; then
    sed -i "/\$activities:/s/icon/default/" src/gnome-shell/sass/_tweaks-temp.scss
  fi
fi

for color in "${_COLOR_VARIANTS[@]}"; do
  for size in "${_SIZE_VARIANTS[@]}"; do
    sassc "${SASSC_OPT[@]}" "src/gtk/3.0/gtk$color$size."{scss,css}
    sassc "${SASSC_OPT[@]}" "src/gtk/4.0/gtk$color$size."{scss,css}
    sassc "${SASSC_OPT[@]}" "src/gnome-shell/shell-3-28/gnome-shell$color$size."{scss,css}
    sassc "${SASSC_OPT[@]}" "src/gnome-shell/shell-40-0/gnome-shell$color$size."{scss,css}
    sassc "${SASSC_OPT[@]}" "src/gnome-shell/shell-42-0/gnome-shell$color$size."{scss,css}
    sassc "${SASSC_OPT[@]}" "src/gnome-shell/shell-44-0/gnome-shell$color$size."{scss,css}
    sassc "${SASSC_OPT[@]}" "src/gnome-shell/shell-46-0/gnome-shell$color$size."{scss,css}
    sassc "${SASSC_OPT[@]}" "src/gnome-shell/shell-47-0/gnome-shell$color$size."{scss,css}
    sassc "${SASSC_OPT[@]}" "src/cinnamon/cinnamon$color$size."{scss,css}
  done
done

echo "== done!"
