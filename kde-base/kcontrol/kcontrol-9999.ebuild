# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
KMNAME=kdebase
KMEXTRACTONLY="kwin/kwinbindings.cpp
	kicker/kicker/core/kickerbindings.cpp
	kicker/taskbar/taskbarbindings.cpp
	kdesktop/kdesktopbindings.cpp
	klipper/klipperbindings.cpp
	kxkb/kxkbbindings.cpp
	kicker/taskmanager"
KMEXTRA="doc/kinfocenter"
KMCOMPILEONLY="kicker/libkicker
	kicker/taskbar"
KMCOPYLIB="libkonq libkonq
	libkicker kicker/libkicker
	libtaskbar kicker/taskbar
	libtaskmanager kicker/taskmanager"
inherit kde-meta eutils
DESCRIPTION="[GIT] The KDE Control Center"
IUSE="arts ieee1394 joystick logitech-mouse opengl kdehiddenvisibility"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"

DEPEND="x11-libs/libXext
	x11-libs/libXtst
	x11-libs/libXcursor
	x11-libs/libXrender
	>=media-libs/freetype-2.3
	media-libs/fontconfig
	dev-libs/openssl
	opengl? ( virtual/opengl )
	ieee1394? ( sys-libs/libraw1394 )
	logitech-mouse? ( =virtual/libusb-0* )
	=kde-base/libkonq-${PV}:${SLOT}
	=kde-base/kicker-${PV}:${SLOT}"
RDEPEND="${DEPEND}
	sys-apps/usbutils
	=kde-base/kcminit-${PV}:${SLOT}
	=kde-base/kdebase-data-${PV}:${SLOT}
	=kde-base/kdesu-${PV}:${SLOT}
	=kde-base/khelpcenter-${PV}:${SLOT}
	=kde-base/khotkeys-${PV}:${SLOT}"

src_unpack() {
	kde-meta_src_unpack unpack

	if ! use joystick ; then
		sed -e 's:$(JOYSTICK_SUBDIR)::' \
			-e 's:kthememanager \\:kthememanager:' \
			-i "${S}/kcontrol/Makefile.am" \
		|| die "sed failed"
	fi
	if ! use arts ; then
		sed -e 's:arts::' \
			-i "${S}/kcontrol/Makefile.am" \
		|| die "sed failed"
	fi

	kde-meta_src_unpack makefiles
}

src_compile() {
	myconf="$myconf --with-ssl $(use_with arts) $(use_with opengl gl)
			$(use_with ieee1394 libraw1394) $(use_with logitech-mouse libusb)
			--with-usbids=/usr/share/misc/usb.ids"
	kde-meta_src_compile
}

src_install() {
	kde-meta_src_install

	# Fix an obscure desktop file that only gets generated during the install phase.
	sed -i -e '$d' "${D}/usr/kde/3.5/share/applications/kde/panel_appearance.desktop"
	sed -i -e 's:Name=panel_appearance::' "${D}/usr/kde/3.5/share/applications/kde/panel_appearance.desktop"
}
