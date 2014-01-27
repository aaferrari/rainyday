# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-action/minetest_game/minetest_game-0.4.7.ebuild,v 1.4 2013/10/27 10:36:10 hasufell Exp $

EAPI=5
inherit games git-2

DESCRIPTION="The main game for the Minetest game engine"
HOMEPAGE="http://github.com/minetest/minetest_game"
EGIT_REPO_URI="http://github.com/minetest/minetest_game.git"

LICENSE="GPL-2 CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc"
IUSE=""

RDEPEND="~games-action/minetest-${PV}[-dedicated]
	=games-action/minetest_common-9999"

src_unpack() {
	git-2_src_unpack
}

src_install() {
	insinto "${GAMES_DATADIR}"/minetest/games/${PN}
	doins -r mods menu
	doins game.conf

	dodoc README.txt

	prepgamesdirs
}