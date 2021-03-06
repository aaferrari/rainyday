# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/kdevelop/kdevelop-3.5.4-r1.ebuild,v 1.9 2009/09/27 14:57:18 ranger Exp $

EAPI=5
ARTS_REQUIRED="never"
KMNAME=kdevelop
inherit kde-meta eutils db-use
DESCRIPTION="[GIT] Integrated Development Environment for Unix, supporting KDE/Qt, C/C++ and many other languages."
HOMEPAGE="http://www.kdevelop.org"
LICENSE="GPL-2"
SLOT="3.5"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="ada clearcase cvs fortran haskell java pascal perforce perl php python ruby sql subversion git vstudio boost"

DEPEND="	sys-devel/gdb
	>=sys-libs/db-4.1
	cvs? ( =kde-base/cervisia-${PV}:${SLOT} )"
RDEPEND="${DEPEND}
	subversion? ( =kde-base/kdesdk-kioslaves-${PV}:${SLOT} )
	boost? ( dev-libs/boost:= )"
DEPEND="${DEPEND}
	>=sys-devel/flex-2.5.33"

REQUIRED_USE="
	vstudio? ( boost )"

EGIT_SOURCE_DIR="${S}"

need-kde 9999

pkg_setup() {
	elog
	elog "If you get build failure similar as bug 237304"
	elog "please build with MAKEOPTS=\"-j1\""
	elog
}

src_unpack() {
	kde-meta_src_unpack
}

src_prepare() {
	# Update the admin dir used in KDE template projects.
	# See also kde bug 104386.
	for i in "${S}"/admin/*; do
		cp "${i}" "${S}/parts/appwizard/common/admin/"
	done

	rm -f "${S}/configure"

	kde_src_prepare
}

src_configure() {
	local myconf
	myconf="--with-kdelibsdoxy-dir=${KDEDIR}/share/doc/HTML/en/kdelibs-apidocs"

	# languages
	myconf="${myconf} $(use_enable java) $(use_enable python)
			$(use_enable ruby) $(use_enable ada) $(use_enable fortran)
			$(use_enable haskell) $(use_enable pascal) $(use_enable perl)
			$(use_enable php) $(use_enable sql) $(use_enable vstudio) $(use_enable boost)"

	# build tools
	myconf="${myconf} $(use_enable java antproject)"

	# version control systems
	myconf="${myconf} $(use_enable cvs) $(use_enable clearcase)
		$(use_enable perforce) $(use_enable subversion)"

	# Explicitly set db include directory (bug 128897)
	myconf="${myconf} --with-db-includedir=$(db_includedir)
			--with-db-lib=$(db_libname)"

	kde_src_configure
}

src_install() {
	kde_src_install

	# Default to exuberant-ctags so that we don't end up trying to run emacs's
	# ctags.
	cat <<-EOF >> "${D}${KDEDIR}/share/config/kdeveloprc"

	[CTAGS]
	ctags binary=/usr/bin/exuberant-ctags

	EOF
}

pkg_postinst() {
	elog "kdevelop can use a wide range of apps for extra functionality. This is an"
	elog "almost complete list. All these packages can be emerged after kdevelop."
	elog
	elog "kde-base/konsole:3.5:		 (RECOMMENDED) embed konsole kpart in kdevelop ide"
	elog "dev-util/kdbg:			 (RECOMMENDED) kde frontend to gdb"
	elog "dev-util/valgrind:		 (RECOMMENDED) integrates valgrind (memory debugger) commands"
	elog "kde-base/kompare:3.5:		 (RECOMMENDED) show differences between files"
	elog "media-gfx/graphviz:		 (RECOMMENDED) support the new graphical classbrowser"
	elog "dev-java/ant:				 support projects using the ant build tool"
	elog "dev-util/ctags:			 faster and more powerful code browsing logic"
	elog "app-doc/doxygen:			 generate KDE-style documentation for your project"
	elog "www-misc/htdig:			 index and search your project's documentation"
	elog "app-arch/rpm:				 support creating RPMs of your project"
	elog "app-emulation/visualboyadvance: create and run projects for this gameboy"
	elog
	elog "Support for GNU-style make, tmake, qmake is included."
	elog "Support for using clearcase, perforce and subversion"
	elog "as version control systems is optional."
	elog
	elog "If you get build failure similar as bug 237304"
	elog "please build with MAKEOPTS=\"-j1\""
	elog
}
