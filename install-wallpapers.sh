#!/bin/bash

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
WALLPAPER_DIR="$HOME/.local/share/backgrounds"

THEME_VARIANTS=('-building' '-mountain' '-flat' '-gradient')
COLOR_VARIANTS=('-morning' '-night' '-day')
SCREEN_VARIANTS=('-1080p' '-2k' '-4k')

#COLORS
CDEF=" \033[0m"                               # default color
CCIN=" \033[0;36m"                            # info color
CGSC=" \033[0;32m"                            # success color
CRER=" \033[0;31m"                            # error color
CWAR=" \033[0;33m"                            # waring color
b_CDEF=" \033[1;37m"                          # bold default color
b_CCIN=" \033[1;36m"                          # bold info color
b_CGSC=" \033[1;32m"                          # bold success color
b_CRER=" \033[1;31m"                          # bold error color
b_CWAR=" \033[1;33m"                          # bold warning color

# echo like ...  with  flag type  and display message  colors
prompt () {
  case ${1} in
    "-s"|"--success")
      echo -e "${b_CGSC}${@/-s/}${CDEF}";;    # print success message
    "-e"|"--error")
      echo -e "${b_CRER}${@/-e/}${CDEF}";;    # print error message
    "-w"|"--warning")
      echo -e "${b_CWAR}${@/-w/}${CDEF}";;    # print warning message
    "-i"|"--info")
      echo -e "${b_CCIN}${@/-i/}${CDEF}";;    # print info message
    *)
    echo -e "$@"
    ;;
  esac
}

usage() {
  cat << EOF
Usage: $0 [OPTION]...

OPTIONS:
  -t, --theme VARIANT     Specify theme variant(s) [building|mountain|flat|gradient] (Default: All variants)s)
  -c, --color VARIANT     Specify color variant(s) [night|light|dark] (Default: All variants)s)
  -s, --screen VARIANT    Specify screen variant [1080p|2k|4k] (Default: 1080p)
  -u, --uninstall         Uninstall wallpappers
  -h, --help              Show help

INSTALLATION EXAMPLES:
Install building night version on 4k display:
  $0 -t building -c night -s 4k
EOF
}

install() {
  local theme="$1"
  local color="$2"
  local screen="$3"

  if [[ "${theme}" == "-flat" || "${theme}" == "-gradient" ]] && [[ "$time_color" == "true" ]]; then
    prompt -e "\n * Fluent${theme} wallpaper don't have color variants... "
    exit 1
  fi

  if [[ "${theme}" != "-flat" && "${theme}" != "-gradient" ]]; then
    prompt -i "\n * Install Fluent${theme}${color} in ${WALLPAPER_DIR}... "
  else
    prompt -i "\n * Install Fluent${theme} in ${WALLPAPER_DIR}... "
  fi

  mkdir -p "${WALLPAPER_DIR}"

  if [[ "${theme}" == "-flat" || "${theme}" == "-gradient" ]]; then
    [[ -f ${WALLPAPER_DIR}/wallpaper-default${theme}.png ]] && rm -rf ${WALLPAPER_DIR}/wallpaper-default${theme}.png
    cp -r ${REPO_DIR}/wallpaper${screen}/wallpaper-default${theme}.png ${WALLPAPER_DIR}
  else
    [[ -f ${WALLPAPER_DIR}/Fluent${theme}${color}.png ]] && rm -rf ${WALLPAPER_DIR}/Fluent${theme}${color}.png
    cp -r ${REPO_DIR}/wallpaper${screen}/Fluent${theme}${color}.png ${WALLPAPER_DIR}
  fi
}

uninstall() {
  local theme="$1"
  local color="$2"
  prompt -i "\n * Uninstall Fluent wallpapers... "
  rm -rf ${WALLPAPER_DIR}/Fluent${theme}${color}.png
  rm -rf ${WALLPAPER_DIR}/wallpaper-default${theme}.png
}

time_color=

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -u|--uninstall)
      uninstall='true'
      shift
      ;;
    -t|--theme)
      shift
      for theme in "$@"; do
        case "$theme" in
          building)
            themes+=("${THEME_VARIANTS[0]}")
            shift 1
            ;;
          mountain)
            themes+=("${THEME_VARIANTS[1]}")
            shift 1
            ;;
          flat)
            themes+=("${THEME_VARIANTS[2]}")
            shift 1
            ;;
          gradient)
            themes+=("${THEME_VARIANTS[3]}")
            shift 1
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized theme variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -c|--color)
      time_color='true'
      shift
      for color in "$@"; do
        case "$color" in
          morning)
            colors+=("${COLOR_VARIANTS[0]}")
            shift 1
            ;;
          night)
            colors+=("${COLOR_VARIANTS[1]}")
            shift 1
            ;;
          day)
            colors+=("${COLOR_VARIANTS[2]}")
            shift 1
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -s|--screen)
      shift
      for screen in "$@"; do
        case "$screen" in
          1080p)
            screens+=("${SCREEN_VARIANTS[0]}")
            shift 1
            ;;
          2k)
            screens+=("${SCREEN_VARIANTS[1]}")
            shift 1
            ;;
          4k)
            screens+=("${SCREEN_VARIANTS[2]}")
            shift 1
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      prompt -e "ERROR: Unrecognized installation option '$1'."
      prompt -i "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [[ "${#themes[@]}" -eq 0 ]] ; then
  themes=("${THEME_VARIANTS[0]}")
fi

if [[ "${#colors[@]}" -eq 0 ]] ; then
  colors=("${COLOR_VARIANTS[@]}")
fi

if [[ "${#screens[@]}" -eq 0 ]] ; then
  screens=("${SCREEN_VARIANTS[0]}")
fi

install_wallpaper() {
  for theme in "${themes[@]}"; do
    for color in "${colors[@]}"; do
      for screen in "${screens[@]}"; do
        install "$theme" "$color" "$screen"
      done
    done
  done
}

uninstall_wallpaper() {
  for theme in "${themes[@]}"; do
    for color in "${colors[@]}"; do
      uninstall "$theme" "$color"
    done
  done
}

echo
if [[ "${uninstall}" != 'true' ]]; then
  install_wallpaper
else
  uninstall_wallpaper
fi
prompt -s "\n * All done!"
echo

