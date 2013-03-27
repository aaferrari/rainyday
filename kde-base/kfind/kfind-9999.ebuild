# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
KMNAME=kdebase
KMCOPYLIB="libkonq libkonq"
inherit kde-meta eutils
DESCRIPTION="[GIT] KDE file find utility"
IUSE="kdehiddenvisibility"

DEPEND="=kde-base/libkonq-${PV}:${SLOT}"
RDEPEND="${DEPEND}"