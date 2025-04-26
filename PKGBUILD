# Maintanier: LieOnLion <lieonlion4@gmail.com>
pkgname=crunched-icon-pack-git
pkgver=1.0
pkgrel=1
pkgdesc="Crunched Icon Theme for linux desktops (an Apple removed/crunched version of Colloid Icon Theme)"
arch=('any')
url="https://github.com/lieonlion/crunched_icon_theme"
license=('GPL')
makedepends=()
depends=()
# conflicts=('') # None
replaces=('crunched-icon-pack')
source=("https://github.com/lieonlion/crunched_icon_theme/archive/refs/heads/main.zip")
sha256sums=("0ba5cbf8de5b7edf1efffa7e476e827ee7f069752a6b87559c975e46b3af0f8a")

package() {
    install -d -m755 "$pkgdir/usr/share/icons/Crunched"

    cp -r "$srcdir/crunched_icon_theme-main/src/." "$pkgdir/usr/share/icons/Crunched/"
}
