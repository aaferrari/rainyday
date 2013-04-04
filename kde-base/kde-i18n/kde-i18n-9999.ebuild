# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=2
KMNAME="kde-i18n"
LICENSE="GPL-2"
WANT_AUTOMAKE="1.11"

inherit eutils kde
DESCRIPTION="[GIT] KDE internationalization package"
HOMEPAGE="http://www.kde.org/"
SLOT="3.5"
IUSE=""
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
# DEPEND="sys-devel/automake"
# RDEPEND="${DEPEND}"

need-kde 9999

LANGS="af ar az bg bn br bs ca cs csb cy da de el en_GB eo es et
eu fa fi fr fy ga gl he hi hr hu is it ja kk km ko lt lv mk
mn ms nb nds nl nn pa pl pt pt_BR ro ru rw se sk sl sr
sr@Latn ss sv ta te tg th tr uk uz uz@cyrillic vi wa zh_CN zh_TW"

for X in ${LANGS} ; do
# 	SRC_URI="${SRC_URI} linguas_${X}? ( mirror://kde/stable/${PV}/src/kde-i18n/kde-i18n-${X}-${PV}.tar.bz2 )"
	IUSE="${IUSE} linguas_${X}"
done

# echo "IUSE: ${IUSE}"

for  X in ${LANGS} ; do
		use linguas_${X} && KMEXTRA="${KMEXTRA} ${X}"
done 

# echo "KMEXTRA: ${KMEXTRA}"

src_unpack() {
	if [[ -z ${LINGUAS} ]] || [[ -z ${A} && "${LINGUAS}" != "en" ]]; then
		echo
		ewarn "You either have the LINGUAS environment variable unset or it"
		ewarn "contains languages not supported by kde-base/kde-i18n."
		ewarn "Because of that, kde-i18n will not add any kind of language"
		ewarn "support."
		ewarn
		ewarn "If you didn't intend this to happen, the available language"
		ewarn "codes are:"
		ewarn "${LANGS}"
		echo
	fi

	# Override kde_src_unpack.
# 	[[ -n ${A} ]] && unpack ${A}
	kde_src_unpack

# 	die "debug"

	# Work around KDE bug 126311.
	for dir in ${LANGS}; do
		KDE_S="${EGIT_SOURCEDIR}/${dir}"

		# Check path for existance
		[[ ! -d ${KDE_S} ]] && continue

		lang=$(echo ${dir} | cut -f3 -d-)

		[[ -e "${EGIT_SOURCEDIR}/${dir}/docs/common/Makefile.in" ]] || continue
		ebegin "Work around KDE bug 126311 for: ${dir}"
		sed -e "s:\$(KDE_LANG)/${lang}/:\$(KDE_LANG)/:g" \
			-i "${EGIT_SOURCEDIR}/${dir}/docs/common/Makefile.in" || die "Failed to fix ${lang}."
		eend ${?}
	done
}

src_configure() {
	for dir in ${LANGS}; do
		KDE_S="${EGIT_SOURCEDIR}/${dir}"

		# Check path for existance
		[[ ! -d ${KDE_S} ]] && continue

		ebegin "Linking admin dir to: ${KDE_S}/admin"
			[[ ! -d "${KDE_S}/admin" || ! -h "${KDE_S}/admin" ]] && ln -s "${WORKDIR}/kdecommon/admin" "${KDE_S}/admin"
		eend ${?}

		kde_src_configure myconf
		myconf="${myconf} --prefix=${KDEDIR}"
		kde_src_configure configure
	done
}

src_compile() {
	for dir in ${LANGS}; do
		KDE_S="${EGIT_SOURCEDIR}/${dir}"

		# Check path for existance
		[[ ! -d ${KDE_S} ]] && continue

# 		kde_src_compile myconf
# 		myconf="${myconf} --prefix=${KDEDIR}"
# 		kde_src_compile configure
		kde_src_compile make
	done
}

src_install() {
	for dir in ${LANGS}; do
		KDE_S="${EGIT_SOURCEDIR}/${dir}"

		# Check path for existance
		[[ ! -d ${KDE_S} ]] && continue

# 		cd "${EGIT_SOURCEDIR}/${dir}"
# 		emake DESTDIR="${D}" install || die

		kde_src_install make
	done
}
