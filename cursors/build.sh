#! /usr/bin/env bash

# check command avalibility
has_command() {
  "$1" -v $1 > /dev/null 2>&1
}

function create {
	cd "$SRC"
	mkdir -p x1 x1_25 x1_5 x2

	cd "$SRC"/$1
	find . -name "*.svg" -type f -exec sh -c 'inkscape -o "../x1/${0%.svg}.png" -w 32 -h 32 $0' {} \;
	find . -name "*.svg" -type f -exec sh -c 'inkscape -o "../x1_25/${0%.svg}.png" -w 40 -w 40 $0' {} \;
	find . -name "*.svg" -type f -exec sh -c 'inkscape -o "../x1_5/${0%.svg}.png" -w 48 -w 48 $0' {} \;
	find . -name "*.svg" -type f -exec sh -c 'inkscape -o "../x2/${0%.svg}.png" -w 64 -w 64 $0' {} \;

	cd "$SRC"

	OUTPUT="$BUILD"/cursors
	ALIASES="$SRC"/cursorList

	if [ ! -d "$BUILD" ]; then
		mkdir "$BUILD"
	fi
	if [ ! -d "$OUTPUT" ]; then
		mkdir "$OUTPUT"
	fi

	echo -ne "Generating cursor theme...\\r"
	for CUR in config/*.cursor; do
		BASENAME="$CUR"
		BASENAME="${BASENAME##*/}"
		BASENAME="${BASENAME%.*}"
		
		xcursorgen "$CUR" "$OUTPUT/$BASENAME"
	done
	echo -e "Generating cursor theme... DONE"

	cd "$OUTPUT"

	#generate aliases
	echo -ne "Generating shortcuts...\\r"
	while read ALIAS; do
		FROM="${ALIAS#* }"
		TO="${ALIAS% *}"

		if [ -e $TO ]; then
			continue
		fi
		ln -sr "$FROM" "$TO"
	done < "$ALIASES"
	echo -e "Generating shortcuts... DONE"

	cd "$PWD"

	echo -ne "Generating Theme Index...\\r"
	INDEX="$OUTPUT/../index.theme"
	if [ ! -e "$OUTPUT/../$INDEX" ]; then
		touch "$INDEX"
		echo -e "[Icon Theme]\nName=$THEME\n" > "$INDEX"
	fi
	echo -e "Generating Theme Index... DONE"
}

if [ ! "$(which xcursorgen 2> /dev/null)" ]; then
  echo xorg-xcursorgen needs to be installed to generate the cursors.
  if has_command zypper; then
    sudo zypper in xorg-xcursorgen
  elif has_command apt; then
    sudo apt install xorg-xcursorgen
  elif has_command dnf; then
    sudo dnf install -y xorg-xcursorgen
  elif has_command dnf; then
    sudo dnf install xorg-xcursorgen
  elif has_command pacman; then
    sudo pacman -S --noconfirm xorg-xcursorgen
  fi
fi

if [ ! "$(which inkscape 2> /dev/null)" ]; then
  echo inkscape needs to be installed to generate the cursors.
  if has_command zypper; then
    sudo zypper in inkscape
  elif has_command apt; then
    sudo apt install inkscape
  elif has_command dnf; then
    sudo dnf install -y inkscape
  elif has_command dnf; then
    sudo dnf install inkscape
  elif has_command pacman; then
    sudo pacman -S --noconfirm inkscape
  fi
fi

# generate pixmaps from svg source
SRC=$PWD/src

THEME="Colloid Cursors"
BUILD="$SRC/../dist"
create svg

THEME="Colloid-dark Cursors"
BUILD="$SRC/../dist-dark"
create svg-white

cd "$SRC"
rm -rf x1 x1_25 x1_5 x2
