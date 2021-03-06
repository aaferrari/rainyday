# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/dssi/dssi-0.9.1.ebuild,v 1.11 2008/07/27 21:08:32 carlo Exp $
EAPI=2

inherit multilib qt3 libtool

IUSE="qt3"

DESCRIPTION="Plugin API for software instruments with user interfaces"
HOMEPAGE="http://dssi.sourceforge.net/"
SRC_URI="mirror://sourceforge/dssi/${P}.tar.gz"

LICENSE="LGPL-2.1 BSD"
SLOT="0"
KEYWORDS="amd64 ppc ppc64 x86"

RDEPEND=">=media-libs/alsa-lib-1.0
	>=media-libs/liblo-0.12
	>=media-sound/jack-audio-connection-kit-0.99.0-r1
	>=media-libs/ladspa-sdk-1.12-r2
	>=media-libs/libsndfile-1.0.11
	>=media-libs/libsamplerate-0.1.1-r1
	qt3? ( dev-qt/qt-meta:3 )"
DEPEND="${RDEPEND}
	sys-apps/sed
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	sed -i -e "s:/lib:/$(get_libdir):" ${S}/dssi.pc.in || die
	elibtoolize
}

src_compile() {
	use qt3 || QTDIR=/WONT_BE_FOUND
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "make install failed"
	dodoc README doc/TODO doc/*.txt
}
