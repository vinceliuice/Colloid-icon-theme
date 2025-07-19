#! /bin/bash

THEME_DIR=$(cd $(dirname $0) && pwd)

THEME_NAME=Colloid
_THEME_VARIANTS=('' '-Purple' '-Pink' '-Red' '-Orange' '-Yellow' '-Green' '-Grey' '-Teal')

if [ ! -z "${COMPA_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _COMPA_VARIANTS <<< "${COMPA_VARIANTS:-}"
fi

if [ ! -z "${COLOR_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _COLOR_VARIANTS <<< "${COLOR_VARIANTS:-}"
fi

if [ ! -z "${THEME_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _THEME_VARIANTS <<< "${THEME_VARIANTS:-}"
fi

Tar_themes() {
for theme in "${_THEME_VARIANTS[@]}"; do
  rm -rf "${THEME_NAME}${theme}.tar.xz"
done

rm -rf "01-${THEME_NAME}.tar.xz"

for theme in "${_THEME_VARIANTS[@]}"; do
  tar -Jcvf "${THEME_NAME}${theme}.tar.xz" "${THEME_NAME}${theme}"{'','-Light','-Dark'}
done

mv "${THEME_NAME}.tar.xz" "01-${THEME_NAME}.tar.xz"
}

Clear_theme() {
for theme in "${_THEME_VARIANTS[@]}"; do
  [[ -d "${THEME_NAME}${theme}" ]] && rm -rf "${THEME_NAME}${theme}"{'','-Light','-Dark'}
done
}

cd .. && ./install.sh -d $THEME_DIR -t all

cd $THEME_DIR && Tar_themes && Clear_theme

mv -f ${THEME_NAME}.tar.xz 01-${THEME_NAME}.tar.xz

