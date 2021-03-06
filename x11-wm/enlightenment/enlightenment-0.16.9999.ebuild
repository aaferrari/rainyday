# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/enlightenment/enlightenment-0.16.9999.ebuild,v 1.40 2012/11/08 07:56:38 vapier Exp $

EAPI=5
SRC_URI=""
EGIT_REPO_URI=${EGIT_REPO_URI:="git://git.enlightenment.org/e16/e16.git"}
EGIT_BRANCH=${EGIT_BRANCH:="master"}
inherit git-support autotools
DESCRIPTION="Enlightenment Window Manager (e16)"
HOMEPAGE="http://www.enlightenment.org/"
LICENSE="BSD"
SLOT=0
IUSE="dbus doc nls pango sound xcomposite xinerama xrandr xsync xpresent xft xi2 glx pseudotrans"
E16_SOUND_MODE=${E16_SOUND_MODE:='pulseaudio'}

RDEPEND="dbus? ( sys-apps/dbus )
	pango? ( x11-libs/pango )
	=media-libs/freetype-2*
	>=media-libs/imlib2-1.3.0[X]
	x11-libs/libSM
	x11-libs/libICE
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXdamage
	x11-libs/libXxf86vm
	x11-libs/libXft
	xrandr? ( x11-libs/libXrandr )
	x11-libs/libXrender
	x11-misc/xbitmaps
	xinerama? ( x11-libs/libXinerama )
	xcomposite? ( x11-libs/libXcomposite )
	nls? ( virtual/libintl )
	virtual/libiconv"
if use sound; then
	case "${E16_SOUND_MODE}" in
		pulseaudio)
			RDEPEND+="media-sound/pulseaudio"
			;;
		esound)
			;;
		no)
			;;
	esac
fi
DEPEND="${RDEPEND}
	virtual/pkgconfig
	x11-proto/xextproto
	x11-proto/xf86vidmodeproto
	xinerama? ( x11-proto/xineramaproto )
	xcomposite? ( x11-proto/compositeproto )
	x11-proto/xproto
	nls? ( sys-devel/gettext )"
PDEPEND="doc? ( app-doc/edox-data )"

S=${WORKDIR}/e16/e
src_prepare() {
	if [[ ! -e configure ]] ; then
		eautopoint
		eautoreconf
	fi
}

src_configure() {
	if use sound; then
		e16sound_cfg="--enable-sound=${E16_SOUND_MODE}"
	else
		e16sound_cfg="--disable-sound"
	fi
	econf \
		--enable-sm \
		$(use_enable xft) \
		$(use_enable xi2) \
		$(use_enable glx) \
		$(use_enable nls) \
		$(use_enable dbus) \
		$(use_enable pango) \
		$(use_enable xinerama) \
		$(use_enable xrandr) \
		$(use_enable xsync) \
		$(use_enable xpresent) \
		$(use_enable xcomposite composite) \
		$(use_enable doc docs) \
		$(use_enable pseudotrans ) \
		${e16sound_cfg} \
		--enable-zoom
}

src_install() {
	default
	dodoc COMPLIANCE sample-scripts/*
	dohtml docs/e16.html
}
