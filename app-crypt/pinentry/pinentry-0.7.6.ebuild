# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/pinentry/pinentry-0.7.6.ebuild,v 1.3 2009/07/15 21:04:10 arfrever Exp $

EAPI=3

inherit qt3 multilib eutils flag-o-matic

DESCRIPTION="Collection of simple PIN or passphrase entry dialogs which utilize the Assuan protocol"
HOMEPAGE="http://www.gnupg.org/aegypten/"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="gtk ncurses qt3 qt4 caps static"

DEPEND="static? ( sys-libs/ncurses )
	!static? (
		gtk? ( x11-libs/gtk+:2 )
		ncurses? ( sys-libs/ncurses )
		qt3? ( dev-qt/qt-meta:3 )
		qt4? ( >=dev-qt/qtgui-4.4.1 )
		!gtk? ( !qt4? ( !qt3? ( !ncurses? ( sys-libs/ncurses ) ) ) )
	)
	caps? ( sys-libs/libcap )"
RDEPEND="${DEPEND}"

pkg_setup() {
	use static && append-ldflags -static

	if use static && { use gtk || use qt3 || use qt4; }
	then
		ewarn
		ewarn "The static USE flag is only supported with the ncurses USE flags, disabling the gtk, qt3 and qt4 USE flags."
		ewarn
	fi
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.7.5-grab.patch"

	if use qt4; then
		local file
		for file in qt4/*.moc; do
			"${EPREFIX}"/usr/bin/moc ${file/.moc/.h} > ${file} || die "moc ${file} failed"
		done
	fi
}

src_configure() {
	local myconf=""

	if ! { use qt3 || use qt4 || use gtk || use ncurses; }
	then
		myconf="--enable-pinentry-curses --enable-fallback-curses"
	elif use static
	then
		myconf="--enable-pinentry-curses --enable-fallback-curses --disable-pinentry-gtk2 --disable-pinentry-qt --disable-pinentry-qt4"
	fi

	# Issues finding qt on multilib systems
	export QTLIB="${QTDIR}/$(get_libdir)"

	econf \
		--disable-dependency-tracking \
		--enable-maintainer-mode \
		--disable-pinentry-gtk \
		$(use_enable gtk pinentry-gtk2) \
		$(use_enable qt3 pinentry-qt) \
		$(use_enable ncurses pinentry-curses) \
		$(use_enable ncurses fallback-curses) \
		$(use_enable qt4 pinentry-qt4) \
		$(use_with caps libcap) \
		${myconf}
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO || die "dodoc failed"
}

pkg_postinst() {
	elog "We no longer install pinentry-curses and pinentry-qt SUID root by default."
	elog "Linux kernels >=2.6.9 support memory locking for unprivileged processes."
	elog "The soft resource limit for memory locking specifies the limit an"
	elog "unprivileged process may lock into memory. You can also use POSIX"
	elog "capabilities to allow pinentry to lock memory. To do so activate the caps"
	elog "USE flag and add the CAP_IPC_LOCK capability to the permitted set of"
	elog "your users."
}
