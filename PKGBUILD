# Maintainer: archcrack <johndoe.arch@outlook.com>
#test
pkgname=isfree
pkgver=0.8.8.2
pkgrel=1
pkgdesc="Check whether there is non-free software in your Archlinux system"
arch=(any)
url="https://github.com/leo-arch/isfree"
license=(GPL2)
depends=('pacman' 'coreutils' 'sed' 'awk' 'grep' 'tar')
makedepends=('git')
source=("git+${url}.git")
sha256sums=('SKIP')

package() {
  cd "${srcdir}/${pkgname}"
  install -Dm755 $pkgname "${pkgdir}/usr/bin/$pkgname"
}
