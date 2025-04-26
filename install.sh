#! /usr/bin/env bash

set -eo pipefail

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.local/share/icons"
fi

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

THEME_NAME=Crunched
THEME_VARIANTS=('' '-Purple' '-Pink' '-Red' '-Orange' '-Yellow' '-Green' '-Teal' '-Grey')
SCHEME_VARIANTS=('' '-Nord' '-Dracula' '-Gruvbox' '-Everforest' '-Catppuccin')
COLOR_VARIANTS=('-Light' '-Dark' '')

themes=()
schemes=()
colors=()

usage() {
cat << EOF
  Usage: $0 [OPTION]...

  OPTIONS:
    -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)
    -n, --name NAME         Specify theme name (Default: $THEME_NAME)
    -s, --scheme VARIANTS   Specify folder colorscheme variant(s) [default|nord|dracula|gruvbox|everforest|catppuccin|all]
    -t, --theme VARIANTS    Specify folder color theme variant(s) [default|purple|pink|red|orange|yellow|green|teal|grey|all] (Default: blue)
    -notint, --notint       Disable Follow ColorSheme for folders on KDE Plasma
    -r, --remove, -u, --uninstall   Remove/Uninstall $THEME_NAME icon themes
    -h, --help              Show help
EOF
}

install() {
  local dest=${1}
  local name=${2}
  local theme=${3}
  local scheme=${4}
  local color=${5}

  local THEME_DIR=${1}/${2}${3}${4}${5}

  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                                  "${THEME_DIR}"
  cp -r "${SRC_DIR}"/src/index.theme                                                        "${THEME_DIR}"
  sed -i "s/Crunched/${2}${3}${4}${5}/g"                                                    "${THEME_DIR}"/index.theme

  if [[ "${color}" == '-Light' ]]; then
    cp -r "${SRC_DIR}"/src/{actions,apps,categories,devices,emblems,mimetypes,places,status} "${THEME_DIR}"

    if [[ "${theme}" == '' && "${scheme}" == '' && "${notint}" == 'true' ]]; then
      cp -r "${SRC_DIR}"/notint/*.svg                                                       "${THEME_DIR}"/places/scalable
    fi

    colors_folder

    if [[ "${scheme}" != '' || "${theme}" != '' ]]; then
      cp -r "${SRC_DIR}"/notint/*.svg                                                       "${THEME_DIR}"/places/scalable
      sed -i "s/#60c0f0/${theme_color}/g"                                                   "${THEME_DIR}"/places/scalable/*.svg
      sed -i "s/#60c0f0/${theme_color}/g"                                                   "${THEME_DIR}"/apps/scalable/*.svg
    fi

    cp -r "${SRC_DIR}"/links/*                                                               "${THEME_DIR}"
  fi

  if [[ "${color}" == '-Dark' ]]; then
    mkdir -p                                                                                "${THEME_DIR}"/{apps,categories,devices,emblems,mimetypes,places,status}
    cp -r "${SRC_DIR}"/src/actions                                                          "${THEME_DIR}"
    cp -r "${SRC_DIR}"/src/apps/{22,symbolic}                                               "${THEME_DIR}"/apps
    cp -r "${SRC_DIR}"/src/categories/{22,symbolic}                                         "${THEME_DIR}"/categories
    cp -r "${SRC_DIR}"/src/emblems/symbolic                                                 "${THEME_DIR}"/emblems
    cp -r "${SRC_DIR}"/src/mimetypes/symbolic                                               "${THEME_DIR}"/mimetypes
    cp -r "${SRC_DIR}"/src/devices/{16,22,24,32,symbolic}                                   "${THEME_DIR}"/devices
    cp -r "${SRC_DIR}"/src/places/{16,22,24,symbolic}                                       "${THEME_DIR}"/places
    cp -r "${SRC_DIR}"/src/status/{16,22,24,symbolic}                                       "${THEME_DIR}"/status

    # Change icon color for dark theme
    sed -i "s/#363636/#dedede/g" "${THEME_DIR}"/{actions,devices,places,status}/{16,22,24}/*.svg
    sed -i "s/#363636/#dedede/g" "${THEME_DIR}"/{actions,devices}/32/*.svg
    sed -i "s/#363636/#dedede/g" "${THEME_DIR}"/apps/22/*.svg
    sed -i "s/#363636/#dedede/g" "${THEME_DIR}"/categories/22/*.svg
    sed -i "s/#363636/#dedede/g" "${THEME_DIR}"/{actions,apps,categories,devices,emblems,mimetypes,places,status}/symbolic/*.svg

    cp -r "${SRC_DIR}"/links/actions/{16,22,24,32,symbolic}                                 "${THEME_DIR}"/actions
    cp -r "${SRC_DIR}"/links/devices/{16,22,24,32,symbolic}                                 "${THEME_DIR}"/devices
    cp -r "${SRC_DIR}"/links/places/{16,22,24,symbolic}                                     "${THEME_DIR}"/places
    cp -r "${SRC_DIR}"/links/status/{16,22,24,symbolic}                                     "${THEME_DIR}"/status
    cp -r "${SRC_DIR}"/links/apps/{22,symbolic}                                             "${THEME_DIR}"/apps
    cp -r "${SRC_DIR}"/links/categories/{22,symbolic}                                       "${THEME_DIR}"/categories
    cp -r "${SRC_DIR}"/links/mimetypes/symbolic                                             "${THEME_DIR}"/mimetypes

    cd "${dest}"
    ln -sf ../../"${name}${theme}${scheme}"-Light/apps/scalable "${name}${theme}${scheme}"-Dark/apps/scalable
    ln -sf ../../"${name}${theme}${scheme}"-Light/devices/scalable "${name}${theme}${scheme}"-Dark/devices/scalable
    ln -sf ../../"${name}${theme}${scheme}"-Light/places/scalable "${name}${theme}${scheme}"-Dark/places/scalable
    ln -sf ../../"${name}${theme}${scheme}"-Light/categories/32 "${name}${theme}${scheme}"-Dark/categories/32
    ln -sf ../../"${name}${theme}${scheme}"-Light/emblems/16 "${name}${theme}${scheme}"-Dark/emblems/16
    ln -sf ../../"${name}${theme}${scheme}"-Light/emblems/22 "${name}${theme}${scheme}"-Dark/emblems/22
    ln -sf ../../"${name}${theme}${scheme}"-Light/status/32 "${name}${theme}${scheme}"-Dark/status/32
    ln -sf ../../"${name}${theme}${scheme}"-Light/mimetypes/scalable "${name}${theme}${scheme}"-Dark/mimetypes/scalable
  fi

  if [[ "${color}" == '' ]]; then
    cd ${dest}
    ln -sf ../"${name}${theme}${scheme}"-Light/apps "${name}${theme}${scheme}"/apps
    ln -sf ../"${name}${theme}${scheme}"-Light/actions "${name}${theme}${scheme}"/actions
    ln -sf ../"${name}${theme}${scheme}"-Light/devices "${name}${theme}${scheme}"/devices
    ln -sf ../"${name}${theme}${scheme}"-Light/emblems "${name}${theme}${scheme}"/emblems
    ln -sf ../"${name}${theme}${scheme}"-Light/places "${name}${theme}${scheme}"/places
    ln -sf ../"${name}${theme}${scheme}"-Light/categories "${name}${theme}${scheme}"/categories
    ln -sf ../"${name}${theme}${scheme}"-Light/mimetypes "${name}${theme}${scheme}"/mimetypes
    ln -sf ../"${name}${theme}${scheme}"-Dark/status "${name}${theme}${scheme}"/status
  fi

  (
    cd "${THEME_DIR}"
    ln -sf actions actions@2x
    ln -sf apps apps@2x
    ln -sf categories categories@2x
    ln -sf devices devices@2x
    ln -sf emblems emblems@2x
    ln -sf mimetypes mimetypes@2x
    ln -sf places places@2x
    ln -sf status status@2x
  )

  gtk-update-icon-cache "${THEME_DIR}"
}

colors_folder() {
  case "$theme" in
    '')
      theme_color='#5b9bf8'
      ;;
    -Purple)
      theme_color='#BA68C8'
      ;;
    -Pink)
      theme_color='#F06292'
      ;;
    -Red)
      theme_color='#F44336'
      ;;
    -Orange)
      theme_color='#FB8C00'
      ;;
    -Yellow)
      theme_color='#FFD600'
      ;;
    -Green)
      theme_color='#66BB6A'
      ;;
    -Teal)
      theme_color='#4DB6AC'
      ;;
    -Grey)
      theme_color='#888888'
      ;;
  esac

  if [[ "$scheme" == '-Nord' ]]; then
    case "$theme" in
      '')
        theme_color='#89a3c2'
        ;;
      -Purple)
        theme_color='#c89dbf'
        ;;
      -Pink)
        theme_color='#dc98b1'
        ;;
      -Red)
        theme_color='#d4878f'
        ;;
      -Orange)
        theme_color='#dca493'
        ;;
      -Yellow)
        theme_color='#eac985'
        ;;
      -Green)
        theme_color='#a0c082'
        ;;
      -Teal)
        theme_color='#83b9b8'
        ;;
      -Grey)
        theme_color='#757a99'
        ;;
    esac
  fi

  if [[ "$scheme" == '-Dracula' ]]; then
    case "$theme" in
      '')
        theme_color='#6272a4'
        ;;
      -Purple)
        theme_color='#bd93f9'
        ;;
      -Pink)
        theme_color='#ff79c6'
        ;;
      -Red)
        theme_color='#ff5555'
        ;;
      -Orange)
        theme_color='#ffb86c'
        ;;
      -Yellow)
        theme_color='#f1fa8c'
        ;;
      -Green)
        theme_color='#50fa7b'
        ;;
      -Teal)
        theme_color='#50fae9'
        ;;
      -Grey)
        theme_color='#757a99'
        ;;
    esac
  fi

  if [[ "$scheme" == '-Gruvbox' ]]; then
    case "$theme" in
      '')
        theme_color='#83a598'
        ;;
      -Purple)
        theme_color='#d386cd'
        ;;
      -Pink)
        theme_color='#d3869b'
        ;;
      -Red)
        theme_color='#fb4934'
        ;;
      -Orange)
        theme_color='#fe8019'
        ;;
      -Yellow)
        theme_color='#fabd2f'
        ;;
      -Green)
        theme_color='#b8bb26'
        ;;
      -Teal)
        theme_color='#8ec07c'
        ;;
      -Grey)
        theme_color='#868686'
        ;;
    esac
  fi

  if [[ "$scheme" == '-Everforest' ]]; then
    case "$theme" in
      '')
        theme_color='#7fbbb3'
        ;;
      -Purple)
        theme_color='#D699B6'
        ;;
      -Pink)
        theme_color='#d3869b'
        ;;
      -Red)
        theme_color='#E67E80'
        ;;
      -Orange)
        theme_color='#E69875'
        ;;
      -Yellow)
        theme_color='#DBBC7F'
        ;;
      -Green)
        theme_color='#A7C080'
        ;;
      -Teal)
        theme_color='#83C092'
        ;;
      -Grey)
        theme_color='#7a8478'
        ;;
    esac
  fi

  if [[ "$scheme" == '-Catppuccin' ]]; then
    case "$theme" in
      '')
        theme_color='#8caaee'
        ;;
      -Purple)
        theme_color='#ca9ee6'
        ;;
      -Pink)
        theme_color='#f4b8e4'
        ;;
      -Red)
        theme_color='#ea999c'
        ;;
      -Orange)
        theme_color='#fe8019'
        ;;
      -Yellow)
        theme_color='#ef9f76'
        ;;
      -Green)
        theme_color='#a6d189'
        ;;
      -Teal)
        theme_color='#81c8be'
        ;;
      -Grey)
        theme_color='#7c7f93'
        ;;
    esac
  fi
}

while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    -d|--dest)
      dest="$2"
      mkdir -p "$dest"
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -r|--remove|-u|--uninstall)
      remove='true'
      echo -e "\nUninstall icon themes...\n"
      shift
      ;;
    -notint|--notint)
      notint='true'
      echo -e "\nInstall notint version! that folders will not follow system colorschemes..."
      shift
      ;;
    -s|--scheme)
      shift
      for scheme in "${@}"; do
        case "${scheme}" in
          default)
            schemes+=("${SCHEME_VARIANTS[0]}")
            shift
            ;;
          nord)
            schemes+=("${SCHEME_VARIANTS[1]}")
            echo -e "\nNord ColorScheme version! ...\n"
            shift
            ;;
          dracula)
            schemes+=("${SCHEME_VARIANTS[2]}")
            echo -e "\nDracula ColorScheme version! ...\n"
            shift
            ;;
          gruvbox)
            schemes+=("${SCHEME_VARIANTS[3]}")
            echo -e "\nGruvbox ColorScheme version! ...\n"
            shift
            ;;
          everforest)
            schemes+=("${SCHEME_VARIANTS[4]}")
            echo -e "\nEverforest ColorScheme version! ...\n"
            shift
            ;;
          catppuccin)
            schemes+=("${SCHEME_VARIANTS[5]}")
            echo -e "\nCatppuccin ColorScheme version! ...\n"
            shift
            ;;
          all)
            schemes+=("${SCHEME_VARIANTS[@]}")
            echo -e "\All ColorSchemes version! ...\n"
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color schemes variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -t|--theme)
      shift
      for theme in "${@}"; do
        case "${theme}" in
          default)
            themes+=("${THEME_VARIANTS[0]}")
            shift
            ;;
          purple)
            themes+=("${THEME_VARIANTS[1]}")
            shift
            ;;
          pink)
            themes+=("${THEME_VARIANTS[2]}")
            shift
            ;;
          red)
            themes+=("${THEME_VARIANTS[3]}")
            shift
            ;;
          orange)
            themes+=("${THEME_VARIANTS[4]}")
            shift
            ;;
          yellow)
            themes+=("${THEME_VARIANTS[5]}")
            shift
            ;;
          green)
            themes+=("${THEME_VARIANTS[6]}")
            shift
            ;;
          teal)
            themes+=("${THEME_VARIANTS[7]}")
            shift
            ;;
          grey)
            themes+=("${THEME_VARIANTS[8]}")
            shift
            ;;
          all)
            themes+=("${THEME_VARIANTS[@]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized theme color variant '$1'."
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
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [[ "${#themes[@]}" -eq 0 ]]; then
  themes=("${THEME_VARIANTS[0]}")
fi

if [[ "${#schemes[@]}" -eq 0 ]]; then
  schemes=("${SCHEME_VARIANTS[0]}")
fi

if [[ "${#colors[@]}" -eq 0 ]]; then
  colors=("${COLOR_VARIANTS[@]}")
fi

clean_old_theme() {
  for theme in '' '-purple' '-pink' '-red' '-orange' '-yellow' '-green' '-teal' '-grey'; do
    for scheme in '' '-nord' '-dracula'; do
      for color in '' '-light' '-dark'; do
        rm -rf "${dest:-${DEST_DIR}}/${THEME_NAME}${theme}${scheme}${color}"
      done
    done
  done
}

remove_theme() {
  for theme in "${THEME_VARIANTS[@]}"; do
    for scheme in "${SCHEME_VARIANTS[@]}"; do
      for color in "${COLOR_VARIANTS[@]}"; do
        local THEME_DIR="${DEST_DIR}/${THEME_NAME}${theme}${scheme}${color}"
        [[ -d "$THEME_DIR" ]] && echo -e "Removing $THEME_DIR ..." && rm -rf "$THEME_DIR"
      done
    done
  done
}

install_theme() {
  for theme in "${themes[@]}"; do
    for scheme in "${schemes[@]}"; do
      for color in "${colors[@]}"; do
        install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${theme}" "${scheme}" "${color}"
      done
    done
  done
}

clean_old_theme

if [[ "${remove}" == 'true' ]]; then
  remove_theme
else
  install_theme
fi

echo -e "\nFinished!\n"


