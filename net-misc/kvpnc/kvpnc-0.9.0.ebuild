# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/kvpnc/kvpnc-0.9.0.ebuild,v 1.9 2009/11/10 23:09:07 cla Exp $

EAPI="1"
ARTS_REQUIRED="never"
inherit kde eutils

DESCRIPTION="kvpnc - a KDE-VPN connection utility."
SRC_URI="http://download.gna.org/${PN}/${P}.tar.bz2"
HOMEPAGE="http://home.gna.org/kvpnc/"
LICENSE="GPL-2"
KEYWORDS="amd64 ppc ppc64 ~sparc x86"
IUSE="+cisco smartcard"
SLOT="3.5"

DEPEND="dev-libs/libgcrypt"
RDEPEND="cisco? ( >=net-misc/vpnc-0.4 )
	smartcard? ( >=dev-libs/openct-0.6.11-r1 )"

need-kde 3.5

src_unpack() {
	kde_src_unpack

	epatch "${FILESDIR}"/kvpnc-0.9.0-gcc43.patch
}
