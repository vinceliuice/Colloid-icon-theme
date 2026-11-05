# Nodalix icon theme

Nodalix maintains this fork of Colloid as the source of its application icons
and Capitaine-based cursor theme. Upstream Colloid credits and licensing are
preserved below.

Custom application artwork lives in `src/apps/scalable`. Application IDs and
short-name aliases live in `links/apps/scalable`. Add a new SVG using its desktop
application ID and rerun the installer to include it in all theme variants.

The current Craft, ArtCraft Launcher, SolidCraft, Audacity 4 Portable, LACT and
The Witcher 3 artwork is included. `nodalix/legacy-icons.json` records hashes of
the previous generated icons so Nodalix OS can adopt those copies while
preserving independently edited icons. Application names and logos belong to
their respective projects.

The Nodalix cursor sources, build tool and LGPL license live in
`cursors/nodalix`. Nodalix OS pins a commit of this repository for both the icon
and cursor packages so a release uses a reproducible set of artwork.

## Colloid icon theme

![1](preview.png?raw=true)

## Donate

If you like my project, you can buy me a coffee:

<span class="paypal"><a href="https://www.paypal.me/vinceliuice" title="Donate to this project using Paypal"><img src="https://www.paypalobjects.com/webstatic/mktg/Logo/pp-logo-100px.png" alt="PayPal donate button" /></a></span>

## Install tips

Usage:  `./install.sh`  **[OPTIONS...]**

```
-d, --dest DIR          Specify destination directory (Default: $HOME/.local/share/icons)
-n, --name NAME         Specify theme name (Default: Colloid)
-s, --scheme VARIANTS   Specify folder colorscheme variant(s) [default|nord|dracula|gruvbox|everforest|catppuccin|all]
-t, --theme VARIANTS    Specify folder color variant(s) [default|purple|pink|red|orange|yellow|green|teal|grey|all] (Default: blue)
-a, --alternative       Install alternative icons for software center and file-manager
-p, --kde-plasma        Replaces Apple logo with KDE Plasma logo.
-b, --bold              Install bolder panel icons version (1.5px size)
-notint, --notint       Disable Follow ColorSheme for folders on KDE Plasma
-h, --help              Show help
```
> For example: install teal nord version -> run: `./install.sh -s nord -t teal`

> For more information, run: `./install.sh -h`

![bold](https://github.com/vinceliuice/WhiteSur-icon-theme/blob/master/bold-size.png?raw=true)

![folders](folders.png?raw=true)

![schemes](schemes.png?raw=true)
