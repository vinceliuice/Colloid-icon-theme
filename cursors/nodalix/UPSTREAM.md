# Capitaine Cursors for Nodalix

Artwork, hotspots, aliases and animation timings come from Capitaine Cursors r4
by Keefer Rourke and contributors, based on KDE Breeze. The original license
is preserved in COPYING (LGPL-3.0-or-later). The original source archive is
https://github.com/keeferrourke/capitaine-cursors/releases/tag/r4 and has SHA-256
41f66e9f4d41729dc5e9185aab3bc4a719fdcca939e6f3f590b6b811b28dedd2.

Nodalix builds the dark SVG artwork into GNOME's scalable format and Xcursor.
The raster sizes include an exact 30 px rendition. The scalable source,
hotspots, animation frame timing and compatibility aliases are retained.

Build with Python, librsvg and xcursorgen installed. The output directory
must be new.

    python3 cursors/nodalix/build.py cursors/nodalix/src /tmp/Nodalix
