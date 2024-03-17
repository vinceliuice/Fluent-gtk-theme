#!/bin/bash

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$REPO_DIR/src"
export LD_LIBRARY_PATH="$REPO_DIR/libsass"
SASSC_BIN="$REPO_DIR/libsass/sassc"

# For tweaks
opacity=
panel=
window=
blur=
outline=
titlebutton=
icon='-default'

THEME_DIR=$(dirname $REPO_DIR)
DEST_DIR=$(dirname $THEME_DIR)
THEME_NAME=$(basename $THEME_DIR)

SASSC_OPT="-M -t expanded"

if [[ "$(command -v gnome-shell)" ]]; then
  gnome-shell --version
  SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -1)"
  if [[ "${SHELL_VERSION:-}" -ge "44" ]]; then
    GS_VERSION="44-0"
  elif [[ "${SHELL_VERSION:-}" -ge "42" ]]; then
    GS_VERSION="42-0"
  elif [[ "${SHELL_VERSION:-}" -ge "40" ]]; then
    GS_VERSION="40-0"
  else
    GS_VERSION="3-28"
  fi

  if [[ "${SHELL_VERSION:-}" -ge "45" ]]; then
    activities="default"
  fi
else
  echo "'gnome-shell' not found, using styles for last gnome-shell version available."
  GS_VERSION="44-0"
fi

theme=
color=
size=

while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    --solid)
      opacity="solid"
      shift
      ;;
    --float)
      panel="float"
      echo -e "Install floating panel version ..."
      shift
      ;;
    --round)
      window="round"
      echo -e "Install rounded windows version ..."
      shift
      ;;
    --blur)
      blur="true"
      panel="compact"
      echo -e "Install blur version ..."
      shift
      ;;
    --noborder)
      outline="false"
      echo -e "Install windows without outline version ..."
      shift
      ;;
    --square)
      titlebutton="square"
      echo -e "Install square windows button version ..."
      shift
      ;;
    --theme)
      accent='true'
      shift
      for variant in "$@"; do
        case "$variant" in
          default)
            theme=''
            shift
            ;;
          purple)
            theme='-purple'
            shift
            ;;
          pink)
            theme='-pink'
            shift
            ;;
          red)
            theme='-red'
            shift
            ;;
          orange)
            theme='-orange'
            shift
            ;;
          yellow)
            theme='-yellow'
            shift
            ;;
          green)
            theme='-green'
            shift
            ;;
          teal)
            theme='-teal'
            shift
            ;;
          grey)
            theme='-grey'
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized theme variant '$1'."
            echo "Ignoring..."
            shift
            ;;
        esac
      done
      ;;
    --icon)
      shift
      for icons in "$@"; do
        case "$icons" in
          default)
            icon='-default'
            shift
            ;;
          apple)
            icon='-apple'
            shift
            ;;
          simple)
            icon='-simple'
            shift
            ;;
          gnome)
            icon='-gnome'
            shift
            ;;
          ubuntu)
            icon='-ubuntu'
            shift
            ;;
          arch)
            icon='-arch'
            shift
            ;;
          manjaro)
            icon='-manjaro'
            shift
            ;;
          fedora)
            icon='-fedora'
            shift
            ;;
          debian)
            icon='-debian'
            shift
            ;;
          void)
            icon='-void'
            shift
            ;;
          opensuse)
            icon='-opensuse'
            shift
            ;;
          popos)
            icon='-popos'
            shift
            ;;
          mxlinux)
            icon='-mxlinux'
            shift
            ;;
          zorin)
            icon='-zorin'
            shift
            ;;
          endeavouros)
            icon='-endeavouros'
            shift
            ;;
          tux)
            icon='-tux'
            shift
            ;;
          nixos)
            icon='-nixos'
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized icon variant '$1'."
            echo "Ignoring..."
            shift
            ;;
        esac
        echo "Install $icons icon for gnome-shell panel..."
      done
      ;;
    --color)
      shift
      for variant in "$@"; do
        case "$variant" in
          standard)
            color=''
            shift
            ;;
          light)
            color='-Light'
            shift
            ;;
          dark)
            color='-Dark'
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Ignoring..."
            shift
            ;;
        esac
      done
      ;;
    --size)
      shift
      for variant in "$@"; do
        case "$variant" in
          standard)
            size=''
            shift
            ;;
          compact)
            size='-compact'
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized size variant '${1:-}'."
            echo "Ignoring..."
            shift
            ;;
        esac
      done
      ;;
    *)
      echo "ERROR: Unrecognized installation option '${1:-}'."
      echo "Ignoring..."
      shift
      ;;
  esac
done

# clean theme
rm -rf "${THEME_DIR}"/{cinnamon,gnome-shell,gtk-2.0,gtk-3.0,gtk-4.0,metacity-1,plank,xfwm4,index.theme}

# install theme
[[ "$color" == '-Dark' ]] && ELSE_DARK="$color"
[[ "$color" == '-Light' ]] && ELSE_LIGHT="$color"
[[ "$color" == '-Dark' ]] || [[ "$color" == '' ]] && ACTIVITIES_ASSETS_SUFFIX="-Dark"

#tweaks
if [[ "$panel" = "float" || "$opacity" == 'solid' || "$window" == 'round' || "$accent" == 'true' || "$blur" == 'true' || "$outline" == 'false' || "$titlebutton" == 'square' ]]; then
  tweaks='true'
  cp -rf ${SRC_DIR}/_sass/_tweaks.scss ${SRC_DIR}/_sass/_tweaks-temp.scss
  cp -rf ${SRC_DIR}/gnome-shell/sass/_tweaks.scss ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
fi

if [[ "$panel" = "float" ]] ; then
  sed -i "/\$panel_style:/s/compact/float/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$panel_style:/s/compact/float/" ${SRC_DIR}/_sass/_tweaks-temp.scss
fi

if [[ "$opacity" = "solid" ]] ; then
  sed -i "/\$opacity:/s/default/solid/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$opacity:/s/default/solid/" ${SRC_DIR}/_sass/_tweaks-temp.scss
  echo -e "Install solid version ..."
fi

if [[ "$window" = "round" ]] ; then
  sed -i "/\$window:/s/default/round/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$window:/s/default/round/" ${SRC_DIR}/_sass/_tweaks-temp.scss
fi

if [[ "$blur" = "true" ]] ; then
  sed -i "/\$blur:/s/false/true/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$blur:/s/false/true/" ${SRC_DIR}/_sass/_tweaks-temp.scss
fi

if [[ "$outline" = "false" ]] ; then
  sed -i "/\$outline:/s/true/false/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$outline:/s/true/false/" ${SRC_DIR}/_sass/_tweaks-temp.scss
fi

if [[ "$titlebutton" = "square" ]] ; then
  sed -i "/\$titlebutton:/s/circular/square/" ${SRC_DIR}/_sass/_tweaks-temp.scss
fi

if [[ "$activities" = "default" ]] ; then
  sed -i "/\$activities:/s/icon/default/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
fi

#install_theme_color
if [[ "$theme" != '' ]]; then
  case "$theme" in
    -purple)
      theme_color='purple'
      ;;
    -pink)
      theme_color='pink'
      ;;
    -red)
      theme_color='red'
      ;;
    -orange)
      theme_color='orange'
      ;;
    -yellow)
      theme_color='yellow'
      ;;
    -green)
      theme_color='green'
      ;;
    -teal)
      theme_color='teal'
      ;;
    -grey)
      theme_color='grey'
      ;;
  esac
  sed -i "/\$theme:/s/default/${theme_color}/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$theme:/s/default/${theme_color}/" ${SRC_DIR}/_sass/_tweaks-temp.scss
fi

echo "Installing '$THEME_DIR'..."

mkdir -p                                                                      "$THEME_DIR"
cp -r "$REPO_DIR/COPYING"                                                     "$THEME_DIR"

echo "[Desktop Entry]" >>                                                     "$THEME_DIR/index.theme"
echo "Type=X-GNOME-Metatheme" >>                                              "$THEME_DIR/index.theme"
echo "Name=$THEME_NAME" >>                                                    "$THEME_DIR/index.theme"
echo "Comment=An Materia Gtk+ theme based on Elegant Design" >>               "$THEME_DIR/index.theme"
echo "Encoding=UTF-8" >>                                                      "$THEME_DIR/index.theme"
echo "" >>                                                                    "$THEME_DIR/index.theme"
echo "[X-GNOME-Metatheme]" >>                                                 "$THEME_DIR/index.theme"
echo "GtkTheme=$THEME_NAME" >>                                                "$THEME_DIR/index.theme"
echo "MetacityTheme=$THEME_NAME" >>                                           "$THEME_DIR/index.theme"
echo "IconTheme=Fluent${ELSE_DARK:-}" >>                           "$THEME_DIR/index.theme"
echo "CursorTheme=Fluent${ELSE_DARK:-}" >>                         "$THEME_DIR/index.theme"
echo "ButtonLayout=close,minimize,maximize:menu" >>                           "$THEME_DIR/index.theme"

# gnome-shell

mkdir -p                                                                      "$THEME_DIR/gnome-shell"
cp -r "$SRC_DIR/gnome-shell/pad-osd.css"                                      "$THEME_DIR/gnome-shell"

$SASSC_BIN $SASSC_OPT "$SRC_DIR/gnome-shell/shell-$GS_VERSION/gnome-shell$color$size.scss" "$THEME_DIR/gnome-shell/gnome-shell.css"

cp -r "${SRC_DIR}/gnome-shell/common-assets"                                  "$THEME_DIR/gnome-shell/assets"
cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/"*.svg                     "$THEME_DIR/gnome-shell/assets"
cp -r "${SRC_DIR}/gnome-shell/theme$theme/"*.svg                              "$THEME_DIR/gnome-shell/assets"
cp -r "${SRC_DIR}/gnome-shell/assets${ACTIVITIES_ASSETS_SUFFIX:-}/activities/activities${icon}.svg" "$THEME_DIR/gnome-shell/assets/activities.svg"

if [[ "$window" = "round" ]] ; then
  cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/buttons-round/"*.svg     "$THEME_DIR/gnome-shell/assets"
else
  cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/buttons/"*.svg           "$THEME_DIR/gnome-shell/assets"
fi

if [[ "$color" = "-Light" ]] ; then
  cp -r "${SRC_DIR}/gnome-shell/assets-Dark/activities/activities${icon}.svg" "$THEME_DIR/gnome-shell/assets/activities-white.svg"
fi

if [[ "$opacity" = "solid" ]] ; then
  if [[ "$window" = "round" ]] ; then
    if [[ "$outline" = "" ]] ; then
      cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/solid-round/"*.svg    "$THEME_DIR/gnome-shell/assets"
    else
      cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/solid-round-borderless/"*.svg "$THEME_DIR/gnome-shell/assets"
    fi
  else
    if [[ "$outline" = "" ]] ; then
      cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/solid/"*.svg           "$THEME_DIR/gnome-shell/assets"
    else
      cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/solid-borderless/"*.svg "$THEME_DIR/gnome-shell/assets"
    fi
  fi
else
  if [[ "$window" = "round" ]] ; then
    if [[ "$outline" = "" ]] ; then
      cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/default-round/"*.svg   "$THEME_DIR/gnome-shell/assets"
    else
      cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/default-round-borderless/"*.svg "$THEME_DIR/gnome-shell/assets"
    fi
  else
    if [[ "$outline" = "" ]] ; then
      cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/default/"*.svg         "$THEME_DIR/gnome-shell/assets"
    else
      cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/default-borderless/"*.svg "$THEME_DIR/gnome-shell/assets"
    fi
  fi
fi

cd "$THEME_DIR/gnome-shell"
ln -sf assets/no-events.svg no-events.svg
ln -sf assets/process-working.svg process-working.svg
ln -sf assets/no-notifications.svg no-notifications.svg

# gtk-2.0

mkdir -p                                                                      "$THEME_DIR/gtk-2.0"
cp -r "$SRC_DIR/gtk-2.0/common/"{apps.rc,hacks.rc,main.rc}                    "$THEME_DIR/gtk-2.0"
cp -r "$SRC_DIR/gtk-2.0/assets-folder/assets$theme${ELSE_DARK:-}"             "$THEME_DIR/gtk-2.0/assets"
cp -r "$SRC_DIR/gtk-2.0/gtkrc$theme${ELSE_DARK:-}"                            "$THEME_DIR/gtk-2.0/gtkrc"

# gtk-3.0

mkdir -p                                                                      "$THEME_DIR/gtk-3.0"
cp -r "$SRC_DIR/gtk/assets$theme"                                             "$THEME_DIR/gtk-3.0/assets"
cp -r "$SRC_DIR/gtk/scalable"                                                 "$THEME_DIR/gtk-3.0/assets"
cp -r "$SRC_DIR/gtk/thumbnail$theme${ELSE_DARK:-}.png"                        "$THEME_DIR/gtk-3.0/thumbnail.png"

$SASSC_BIN $SASSC_OPT "$SRC_DIR/gtk/3.0/gtk$color$size.scss"                  "$THEME_DIR/gtk-3.0/gtk.css"
$SASSC_BIN $SASSC_OPT "$SRC_DIR/gtk/3.0/gtk-Dark$size.scss"                   "$THEME_DIR/gtk-3.0/gtk-dark.css"

# gtk-4.0

mkdir -p                                                                      "$THEME_DIR/gtk-4.0"
cp -r "$SRC_DIR/gtk/assets$theme"                                             "$THEME_DIR/gtk-4.0/assets"
cp -r "$SRC_DIR/gtk/scalable"                                                 "$THEME_DIR/gtk-4.0/assets"

$SASSC_BIN $SASSC_OPT "$SRC_DIR/gtk/4.0/gtk$color$size.scss"                  "$THEME_DIR/gtk-4.0/gtk.css"
$SASSC_BIN $SASSC_OPT "$SRC_DIR/gtk/4.0/gtk-Dark$size.scss"                   "$THEME_DIR/gtk-4.0/gtk-dark.css"

# cinnamon

mkdir -p                                                                      "$THEME_DIR/cinnamon"
cp -r "$SRC_DIR/cinnamon/common-assets"                                       "$THEME_DIR/cinnamon/assets"
cp -r "$SRC_DIR/cinnamon/assets${ELSE_DARK:-}/"*.svg                          "$THEME_DIR/cinnamon/assets"

$SASSC_BIN $SASSC_OPT "$SRC_DIR/cinnamon/cinnamon$color$size.scss"            "$THEME_DIR/cinnamon/cinnamon.css"

cp -r "$SRC_DIR/cinnamon/thumbnail$theme$color.png"                           "$THEME_DIR/cinnamon/thumbnail.png"

# xfwm4

mkdir -p                                                                      "$THEME_DIR/xfwm4"

if [[ "$titlebutton" = "square" ]] ; then
  cp -r "$SRC_DIR/xfwm4/assets-square$color/"*.png                            "$THEME_DIR/xfwm4"
  cp -r "$SRC_DIR/xfwm4/themerc-square${ELSE_LIGHT:-}"                        "$THEME_DIR/xfwm4/themerc"
else
  cp -r "$SRC_DIR/xfwm4/assets$color/"*.png                                   "$THEME_DIR/xfwm4"
  cp -r "$SRC_DIR/xfwm4/themerc${ELSE_LIGHT:-}"                               "$THEME_DIR/xfwm4/themerc"
fi

# metacity

mkdir -p                                                                      "$THEME_DIR/metacity-1"
cp -r "$SRC_DIR/metacity-1/metacity-theme-2$color.xml"                        "$THEME_DIR/metacity-1/metacity-theme-2.xml"

if [[ "$window" = "round" ]] ; then
  cp -r "$SRC_DIR/metacity-1/metacity-theme-3-round.xml"                      "$THEME_DIR/metacity-1/metacity-theme-3.xml"
  cp -r "$SRC_DIR/metacity-1/assets-round"                                    "$THEME_DIR/metacity-1/assets"
else
  cp -r "$SRC_DIR/metacity-1/metacity-theme-3.xml"                            "$THEME_DIR/metacity-1"
  cp -r "$SRC_DIR/metacity-1/assets"                                          "$THEME_DIR/metacity-1"
fi

cp -r "$SRC_DIR/metacity-1/thumbnail${ELSE_DARK:-}.png"                       "$THEME_DIR/metacity-1/thumbnail.png"
cd "$THEME_DIR/metacity-1" && ln -sf metacity-theme-2.xml metacity-theme-1.xml

# plank

mkdir -p                                                                      "$THEME_DIR/plank"
cp -r "$SRC_DIR/plank/theme${ELSE_LIGHT:-}/dock.theme"                        "$THEME_DIR/plank"

echo
echo "Done."
