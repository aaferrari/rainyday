# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
KMNAME=kdemultimedia
KMEXTRACTONLY="arts/"
inherit kde-meta eutils
DESCRIPTION="[GIT] The Lean KDE Media Player"
IUSE=""
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"

# OLDRDEPEND="~kde-base/kdemultimedia-arts-${PV}"
RDEPEND="
=kde-base/kdemultimedia-arts-${PV}:${SLOT}
"
