# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/kdbg/kdbg-2.1.0.ebuild,v 1.7 2009/10/03 20:04:44 sping Exp $
EAPI=2
ARTS_REQUIRED="never"

inherit kde

DESCRIPTION="A Graphical Debugger Interface to gdb."
HOMEPAGE="http://www.kdbg.org/"
SRC_URI="mirror://sourceforge/kdbg/${P}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="amd64 ppc ppc64 sparc x86"
IUSE=""

RDEPEND=">=sys-devel/gdb-5.0"

need-kde 3.5

PATCHES=( "${FILESDIR}"/${PN}-2.1.0-desktop-entry.diff
		"${FILESDIR}"/${PN}-2.1.0-move-kde-ldflags-up-front.patch )
