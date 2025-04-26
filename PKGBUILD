# Maintanier: LieOnLion <lieonlion4@gmail.com>
pkgname=crunched-icon-pack-git
pkgver=1.0
pkgrel=1
pkgdesc="Crunched Icon Theme for linux desktops (an Apple removed/crunched version of Colloid Icon Theme)"
arch=('any')
url="https://github.com/lieonlion/crunched_icon_theme.git"
license=('GPL')
makedepends=()
depends=()
conflicts=() # None
replaces=() # None
source=("git+$url")
md5sums=("SKIP")

pkgver() {
    printf "1.0.r%s" "$(git rev-list --count HEAD)"
}

package() {
    cd ..
    sudo ./install.sh
}
