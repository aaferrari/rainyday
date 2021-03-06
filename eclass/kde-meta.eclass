# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/kde-meta.eclass,v 1.91 2009/10/15 22:18:17 abcd Exp $

# @ECLASS: kde-meta.eclass
# @MAINTAINER:
# kde@gentoo.org
#
# Original authors:
# Dan Armak <danarmak@gentoo.org>
# Simone Gotti <motaboy@gentoo.org>
# @BLURB: This is the kde-meta eclass which supports broken-up kde-base packages.
# @DESCRIPTION:
# This is the kde-meta eclass which supports broken-up kde-base packages.

inherit kde multilib git-support

# only broken-up ebuilds can use this eclass
if [[ -z "$KMNAME" ]]; then
	die "kde-meta.eclass inherited but KMNAME not defined - broken ebuild"
fi

# Replace the $myPx mess - it was ugly as well as not general enough for 3.4.0-rc1
# The following code should set TARBALLVER (the version in the tarball's name)
# and TARBALLDIRVER (the version of the toplevel directory inside the tarball).
case "$PV" in
	3.5.0_beta2)		TARBALLDIRVER="3.4.92"; TARBALLVER="3.4.92" ;;
	3.5.0_rc1)		TARBALLDIRVER="3.5.0"; TARBALLVER="3.5.0_rc1" ;;
	*)				TARBALLDIRVER="$PV"; TARBALLVER="$PV" ;;
esac

if [[ "${KMNAME}" = "koffice" ]]; then
	case "$PV" in
		1.6_beta1)	TARBALLDIRVER="1.5.91"; TARBALLVER="1.5.91" ;;
		1.6_rc1)	TARBALLDIRVER="1.5.92"; TARBALLVER="1.5.92" ;;
		1.6.3_p*)	TARBALLDIRVER="1.6.3"; TARBALLVER="${PV}" ;;
	esac
fi

TARBALL="$KMNAME-$TARBALLVER.tar.bz2"

# BEGIN adapted from kde-dist.eclass, code for older versions removed for cleanness
if [[ "$KDEBASE" = "true" ]]; then
	unset SRC_URI

	need-kde $PV

	DESCRIPTION="KDE ${PV} - "
	HOMEPAGE="http://www.kde.org/"
	LICENSE="GPL-2"
	SLOT="$KDEMAJORVER.$KDEMINORVER"

	# Main tarball for normal downloading style
	# Note that we set SRC_PATH, and add it to SRC_URI later on
	case "$PV" in
		3.5.0_*)
			SRC_PATH="mirror://kde/unstable/${PV/.0_/-}/src/$TARBALL"
			SRC_URI="$SRC_URI $SRC_PATH"
		;;
		3.5_*)
			SRC_PATH="mirror://kde/unstable/${PV/_/-}/src/$TARBALL"
			SRC_URI="$SRC_URI $SRC_PATH"
			;;
		3.5.0)
			SRC_PATH="mirror://kde/stable/3.5/src/$TARBALL"
			SRC_URI="$SRC_URI $SRC_PATH"
		;;
		3*)
			SRC_PATH="mirror://kde/stable/$TARBALLVER/src/$TARBALL"
			SRC_URI="$SRC_URI $SRC_PATH"
		;;
		9999)
			SRC_PATH=""
			SRC_URI=""
			SLOT="3.5" # We are developing for kde 3.5
		;;
		*)
			die "$ECLASS: Error: unrecognized version $PV, could not set SRC_URI"
		;;
	esac
elif [[ "$KMNAME" == "koffice" ]]; then
	SRC_PATH="mirror://kde/stable/koffice-$PV/src/koffice-$PV.tar.bz2"

	case $PV in
		1.3.5)
			SRC_PATH="mirror://kde/stable/koffice-$PV/src/koffice-$PV.tar.bz2"
		;;
		1.6_beta1)
			SRC_PATH="mirror://kde/unstable/koffice-${PV/_/-}/koffice-${TARBALLVER}.tar.bz2"
		;;
		1.6.3_p*)
			SRC_PATH="mirror://gentoo/${TARBALL}"
		;;
		*)
			# Identify beta and rc versions by underscore
			if [[ ${PV/_/} != ${PV} ]]; then
				SRC_PATH="mirror://kde/unstable/koffice-${PV/_/-}/src/koffice-${TARBALLVER}.tar.bz2"
			fi
		;;
	esac

	SRC_URI="$SRC_URI $SRC_PATH"
fi

# SRC_URI="$SRC_URI $SRC_PATH"
# debug-print "SRC_PATH: $SRC_PATH"
# SRC_URI=""
# debug-print "$ECLASS: finished, SRC_URI=$SRC_URI"

# Add a blocking dep on the package we're derived from
if [[ "${KMNAME}" != "koffice" ]]; then
	DEPEND="${DEPEND} !=$(get-parent-package ${CATEGORY}/${PN})-${SLOT}*"
	RDEPEND="${RDEPEND} !=$(get-parent-package ${CATEGORY}/${PN})-${SLOT}*"
else
	case ${EAPI:-0} in
		0)
		# EAPIs without SLOT dependencies.
		IFSBACKUP="$IFS"
		IFS=".-_"
		for x in ${PV}; do
			if [[ -z "$KOFFICEMAJORVER" ]]; then KOFFICEMAJORVER=$x
			else if [[ -z "$KOFFICEMINORVER" ]]; then KOFFICEMINORVER=$x
			else if [[ -z "$KOFFICEREVISION" ]]; then KOFFICEREVISION=$x
			fi; fi; fi
		done
		[[ -z "$KOFFICEMINORVER" ]] && KOFFICEMINORVER="0"
		[[ -z "$KOFFICEREVISION" ]] && KOFFICEREVISION="0"
		IFS="$IFSBACKUP"
		DEPEND="${DEPEND} !=$(get-parent-package ${CATEGORY}/${PN})-${KOFFICEMAJORVER}.${KOFFICEMINORVER}*"
		RDEPEND="${RDEPEND} !=$(get-parent-package ${CATEGORY}/${PN})-${KOFFICEMAJORVER}.${KOFFICEMINORVER}*"
		;;
		# EAPIs with SLOT dependencies.
		*)
		[[ -z ${SLOT} ]] && SLOT="0"
		DEPEND="${DEPEND} !$(get-parent-package ${CATEGORY}/${PN}):${SLOT}"
		RDEPEND="${RDEPEND} !$(get-parent-package ${CATEGORY}/${PN}):${SLOT}"
		;;
	esac
fi

# @ECLASS-VARIABLE: KMNAME
# @DESCRIPTION:
# Name of the metapackage (eg kdebase, kdepim). Must be set before inheriting
# this eclass, since it affects $SRC_URI. This variable MUST be set.

# @ECLASS-VARIABLE: KMNOMODULE
# @DESCRIPTION:
# Unless set to "true", then KMMODULE will be not defined and so also the docs.
# Useful when we want to installs subdirs of a subproject, like plugins, and we
# have to mark the topsubdir ad KMEXTRACTONLY.

# @ECLASS-VARIABLE: KMMODULE
# @DESCRIPTION:
# Defaults to $PN. Specify one subdirectory of KMNAME. Is treated exactly like items in KMEXTRA.
# Fex., the ebuild name of kdebase/l10n is kdebase-l10n, because just 'l10n' would be too confusing.
# Do not include the same item in more than one of KMMODULE, KMMEXTRA, KMCOMPILEONLY, KMEXTRACTONLY, KMCOPYLIB.

# @ECLASS-VARIABLE: KMNODOCS
# @DESCRIPTION:
# Unless set to "true", 'doc/$KMMODULE' is added to KMEXTRA. Set for packages that don't have docs.

# @ECLASS-VARIABLE: KMEXTRA
# @DESCRIPTION:
# Specify files/dirs to extract, compile and install. $KMMODULE is added to
# KMEXTRA automatically. So is doc/$KMMODULE (unless $KMNODOCS==true). Makefiles
# are created automagically to compile/install the correct files. Observe these
# rules:
#
# - Don't specify the same file in more than one of three variables (KMEXTRA,
# KMCOMPILEONLY, and KMEXTRACTONLY)
# - When using KMEXTRA, remember to add the doc/foo dir for the extra dirs if one exists.
# - KMEXTRACTONLY take effect over an entire directory tree, you can override it defining
#
# KMEXTRA, KMCOMPILEONLY for every subdir that must have a different behavior.
# eg. you have this tree:
# foo/bar
# foo/bar/baz1
# foo/bar/baz1/taz
# foo/bar/baz2
# If you define:
# KMEXTRACTONLY=foo/bar and KMEXTRA=foo/bar/baz1
# then the only directory compiled will be foo/bar/baz1 and not foo/bar/baz1/taz (also if it's a subdir of a KMEXTRA) or foo/bar/baz2
#
# IMPORTANT!!! you can't define a KMCOMPILEONLY SUBDIR if its parents are defined as KMEXTRA or KMMODULE. or it will be installed anywhere. To avoid this probably are needed some chenges to the generated Makefile.in.
# Do not include the same item in more than one of KMMODULE, KMMEXTRA, KMCOMPILEONLY, KMEXTRACTONLY, KMCOPYLIB.

# @ECLASS-VARIABLE: KMCOMPILEONLY
# @DESCRIPTION:
# Please see KMEXTRA

# @ECLASS-VARIABLE: KMEXTRACTONLY
# @DESCRIPTION:
# Please see KMEXTRA

# @ECLASS-VARIABLE: KMCOPYLIB
# @DESCRIPTION:
# Contains an even number of $IFS (i.e. whitespace) -separated words.
# Each two consecutive words, libname and dirname, are considered. symlinks are created under $S/$dirname
# pointing to $PREFIX/lib/libname*.
# Do not include the same item in more than one of KMMODULE, KMMEXTRA, KMCOMPILEONLY, KMEXTRACTONLY, KMCOPYLIB.


# ====================================================

# @FUNCTION: create_fullpaths
# @DESCRIPTION:
# create a full path vars, and remove ALL the endings "/"
create_fullpaths() {
	for item in $KMMODULE; do
		KMMODULEFULLPATH="$KMMODULEFULLPATH ${S}/${item%/}"
	done
	for item in $KMEXTRA; do
		KMEXTRAFULLPATH="$KMEXTRAFULLPATH ${S}/${item%/}"
	done
	for item in $KMCOMPILEONLY; do
		KMCOMPILEONLYFULLPATH="$KMCOMPILEONLYFULLPATH ${S}/${item%/}"
	done
	for item in $KMEXTRACTONLY; do
		KMEXTRACTONLYFULLPATH="$KMEXTRACTONLYFULLPATH ${S}/${item%/}"
	done

	debug-print "KMMODULEFULLPATH: $KMMODULEFULLPATH"
	debug-print "KMEXTRAFULLPATH: $KMEXTRAFULLPATH"
	debug-print "KMCOMPILEONLYFULLPATH: $KMCOMPILEONLYFULLPATH"
	debug-print "KMEXTRACTONLYFULLPATH: $KMEXTRACTONLYFULLPATH"
}

# @FUNCTION: change_makefiles
# @USAGE: < dir > < isextractonly >
# @DESCRIPTION:
# Creates Makefile.am files in directories where we didn't extract the originals.
# $isextractonly: true if the parent dir was defined as KMEXTRACTONLY
# Recurses through $S and all subdirs. Creates Makefile.am with SUBDIRS=<list of existing subdirs>
# or just empty all:, install: targets if no subdirs exist.
change_makefiles() {
	debug-print-function $FUNCNAME "$@"
	local dirlistfullpath dirlist directory isextractonly

	cd "${1}"
	debug-print "We are in ${PWD}"

	# check if the dir is defined as KMEXTRACTONLY or if it was defined is KMEXTRACTONLY in the parent dir, this is valid only if it's not also defined as KMMODULE, KMEXTRA or KMCOMPILEONLY. They will ovverride KMEXTRACTONLY, but only in the current dir.
	isextractonly="false"
	if ( ( has "$1" $KMEXTRACTONLYFULLPATH || [[ $2 = "true" ]] ) && \
		 ( ! has "$1" $KMMODULEFULLPATH $KMEXTRAFULLPATH $KMCOMPILEONLYFULLPATH ) ); then
		isextractonly="true"
	fi
	debug-print "isextractonly = $isextractonly"

	dirlistfullpath=
	for item in *; do
		if [[ -d "${item}" && "${item}" != "CVS" && "${S}/${item}" != "${S}/admin" ]]; then
			# add it to the dirlist, with the FULL path and an ending "/"
			dirlistfullpath="$dirlistfullpath ${1}/${item}"
		fi
	done
	debug-print "dirlist = $dirlistfullpath"

	for directory in $dirlistfullpath; do

		if ( has "$1" $KMEXTRACTONLYFULLPATH || [[ $2 = "true" ]] ); then
			change_makefiles $directory 'true'
		else
			change_makefiles $directory 'false'
		fi
		# come back to our dir
		cd $1
	done

	cd $1
	debug-print "Come back to ${PWD}"
	debug-print "dirlist = $dirlistfullpath"
	if [[ $isextractonly = "true" ]] || [[ ! -f Makefile.am ]] ; then
		# if this is a latest subdir
		if [[ -z "$dirlistfullpath" ]]; then
			debug-print "dirlist is empty => we are in the latest subdir"
			echo 'all:' > Makefile.am
			echo 'install:' >> Makefile.am
			echo '.PHONY: all' >> Makefile.am
		else # it's not a latest subdir
			debug-print "We aren't in the latest subdir"
			# remove the ending "/" and the full path"
			for directory in $dirlistfullpath; do
				directory=${directory%/}
				directory=${directory##*/}
				dirlist="$dirlist $directory"
			done
			echo "SUBDIRS=$dirlist" > Makefile.am
		fi
	fi
}

set_common_variables() {
	# Overridable module (subdirectory) name, with default value
	if [[ "$KMNOMODULE" != "true" ]] && [[ -z "$KMMODULE" ]]; then
		KMMODULE=$PN
	fi

	# Unless disabled, docs are also extracted, compiled and installed
	DOCS=""
	if [[ "$KMNOMODULE" != "true" ]] && [[ "$KMNODOCS" != "true" ]]; then
		DOCS="doc/$KMMODULE"
	fi
}

# @FUNCTION: kde-meta_src_unpack
# @USAGE: [ unpack ] [ makefiles ]
# @DESCRIPTION:
# This has function sections now. Call unpack, apply any patches not in $PATCHES,
# then call makefiles.
kde-meta_src_unpack() {
	debug-print-function $FUNCNAME "$@"

	set_common_variables

	sections="$@"
	echo "sections: $sections"

	[[ -z "$sections" ]] && sections="unpack makefiles"
	for section in $sections; do
	case $section in
	unpack)

		# kdepim packages all seem to rely on libkdepim/kdepimmacros.h
		# also, all kdepim Makefile.am's reference doc/api/Doxyfile.am
		if [[ "$KMNAME" == "kdepim" ]]; then
			KMEXTRACTONLY="$KMEXTRACTONLY libkdepim/kdepimmacros.h doc/api"
		fi

		EGIT_KDE_REPO_URI_BASE=${EGIT_KDE_REPO_URI_BASE:="git://github.com/iegor"}
		EGIT_REPO_URI="${EGIT_KDE_REPO_URI_BASE}/${KMNAME}.git"
		EGIT_BRANCH="${KMBRANCH:=${EGIT_BRANCH:=develop}}"
		EGIT_PROJECT="${KMNAME}.git"

		# Short debug messaging, log
		debug-print "S: $S"
		debug-print "A: $A"
		debug-print "P: $P"
		debug-print "PN: $PN"
		debug-print "PV: $PV"
		debug-print "DISTDIR: ${DISTDIR}"
		debug-print "D: ${D}"
		debug-print "WORKDIR: $WORKDIR";
		if [ "${ECLASS_DEBUG_OUTPUT}" == "on" ]; then
			if [ -d ${WORKDIR} ]; then
				einfo "workdir exist."
				ls -la ${WORKDIR}
			fi
		fi
		debug-print "pwd: $(pwd)"
		debug-print "T: $T"
		debug-print "KMNAME: ${KMNAME}"
		debug-print "KMMODULE: ${KMMODULE}"
		# debug-print "files list: ${extractlist}"
		debug-print "EGIT_SOURCEDIR: ${EGIT_SOURCEDIR}"
		debug-print "EGIT_BRANCH: ${EGIT_BRANCH}"

		git-support_init_variables

		if [[ ${EVCS_OFLINE} ]]; then
			ewarn "No network connection!!!"
			einfo "we can't fetch sources from online git repo."
			einfo "No worries though! If you are on development machine"
			einfo "or set up git service on this machine and did placed"
			einfo "kde modules there, you can clone/fetch from there"
			rc-service git-daemon status > /dev/null
			if [[ ${?} == 3 ]]; then
				einfo "Please run the git service and restart emerge process"
			fi
		fi

		git-support_prepare_storedir
		git-support_migrate_repository
		git-support_fetch
		git-support_gc
		# git-support_submodules

		# To make sure we are checking out into workdir
		# S="${WORKDIR}"/${P}
		# dodir ${S}
		# dodir ${EGIT_SOURCEDIR}
		git-support_move_source
		cd ${EGIT_SOURCEDIR}

		if [ "${KMNAME}" == "${PN}" ]; then
			# For modules sized projecs (like amarok, etc)
			ebegin "Checking out whole module"
				git checkout origin/${EGIT_BRANCH} . &> /dev/null
				kmmodule_co_ok=${?}
			eend ${?}

			if [ ${kmmodule_co_ok} -ne 0 ]; then
				die "KMMODULE [${KMMODULE}] is not found in ${EGIT_REPO_URI} branch ${EGIT_BRANCH}"
			fi
		else
			for item in Makefile.am Makefile.am.in configure.in.in configure.in.mid \
				configure.in.bot acinclude.m4 aclocal.m4 AUTHORS COPYING INSTALL \
				README NEWS ChangeLog ${KMEXTRA} ${KMCOMPILEONLY} \
				${KMEXTRACTONLY} ${DOCS}
			do
				ebegin "<co>: ${KMNAME}@${EGIT_BRANCH} - ${item%/}"
					git checkout origin/${EGIT_BRANCH} "${item%/}" &> /dev/null
				eend ${?}
			done
			# einfo "getting \".in.in\" file so configure atempt would be much more precise"
			# for km_exo in ${KMEXTRACTONLY}; do
			#	einfo "[ ${km_exo} ]"
			#	# ebegin "[git: co] "
			# done

			ebegin "<co>: ${KMNAME}@${EGIT_BRANCH} - ${KMMODULE}"
				git checkout origin/${EGIT_BRANCH} "${KMMODULE}" &> /dev/null
				kmmodule_co_ok=${?}
			eend ${kmmodule_co_ok}

			if [ ${kmmodule_co_ok} -ne 0 ]; then
				die "KMMODULE [${KMMODULE}] is not found in ${EGIT_REPO_URI} branch ${EGIT_BRANCH}"
			fi
		fi

		ebegin "<co>: submodule files"
			git checkout origin/${EGIT_BRANCH} ".gitmodules" &> /dev/null
		eend ${?}

		ebegin "<co>: \"admin\" submodule"
			# Set url to admin module depending on our {offline|online} behaviour
			git config --local submodule.admin.url "${EGIT_KDE_REPO_URI_BASE}/kde-common-admin.git"
			git checkout origin/${EGIT_BRANCH} "admin" &> /dev/null
		eend ${?}

		git submodule init || die "Failed to init submodule"
		git submodule update || die "Failed to update submodule"

		if [ "${ECLASS_DEBUG_OUTPUT}" == "on" ]; then
			echo "##################################### DEBUG: git log"
			git --no-pager log --all -n25 --oneline --abbrev=8 --graph --topo-order --color=always \
				--pretty="> %h (%Cred%t%Creset) (%Cgreen%p%Creset) - %Cblue%an(%cn)%Creset \"%s\" %C(bold green)%d%Creset"
			echo "####################################################"
		fi

		# Don't add a param here without looking at its implementation.
		# kde_src_unpack

		# Copy over KMCOPYLIB items
		libname=""
		for x in $KMCOPYLIB; do
			if [[ "$libname" == "" ]]; then
				libname=$x
			else
				dirname=$x
				cd "${S}"
				mkdir -p ${dirname}
				cd ${dirname}
				search_path=$(echo "${PREFIX}"/$(get_libdir)/{,kde3/{,plugins/{designer,styles}}})
				if [[ ! "$(find ${search_path} -maxdepth 1 -name "${libname}*" 2>/dev/null)" == "" ]]; then
					if [ "${ECLASS_DEBUG_OUTPUT}" == "on" ]; then
						einfo "Symlinking library: \"${PREFIX}/$(get_libdir)/${libname}\" -> ./"
					fi
					ln -s "${PREFIX}"/$(get_libdir)/${libname}* .
				else
					die "Can't find library ${libname} under ${PREFIX}/$(get_libdir)/"
				fi
				libname=""
			fi
		done

		# $KMTARPARAMS is also available for an ebuild to use; currently used by kturtle
		TARFILE=$DISTDIR/$TARBALL
		KMTARPARAMS="$KMTARPARAMS -j"
		cd "${WORKDIR}"

		# unpack patchsets, usually
		debug-print "[[ -n ${A/${TARBALL}/} ]] && unpack ${A/${TARBALL}/}"
		[[ -n ${A/${TARBALL}/} ]] && unpack ${A/${TARBALL}/}

		# Avoid syncing if possible
		# No idea what the above comment means...
		if [[ -n "$RAWTARBALL" ]]; then
			rm -f "${T}"/$RAWTARBALL
		fi

		# kdebase: Remove the installation of the "startkde" and "kde3" scripts.
		if [[ "$KMNAME" == "kdebase" ]]; then
			sed -i -e s:"bin_SCRIPTS = startkde.*"::g "${S}"/Makefile.am.in
		fi
	;;
	makefiles)

		case ${EAPI:-0} in
			0|1) kde-meta_src_prepare ;;
		esac

	;;
	esac
	done

	# for ebuilds with extended src_unpack
	cd "${S}"
}

# @FUNCTION: kde-meta_src_prepare
# @DESCRIPTION:
# Source tree preparation compatible with eapi 2
kde-meta_src_prepare() {
	debug-print-function $FUNCNAME "$@"

	set_common_variables

	case ${EAPI:-0} in
		0|1) ;; # Don't call kde_src_prepare, as kde_src_unpack already did so
		*) kde_src_prepare ;;
	esac

	# Create Makefile.am files
	create_fullpaths
	change_makefiles "${S}" "false"
}

# @FUNCTION: kde-meta_src_configure
# @DESCRIPTION:
# Configure stub for eapi 2
kde-meta_src_configure() {
	debug-print-function $FUNCNAME "$@"

	set_common_variables

	if [[ "$KMNAME" == "kdebase" ]]; then
		# bug 82032: the configure check for java is unnecessary as well as broken
		myconf="$myconf --without-java"
	fi

	if [[ "$KMNAME" == "kdegames" ]]; then
		# make sure games are not installed with setgid bit, as it is a security risk.
		myconf="$myconf --disable-setgid"
	fi

	# Make sure kde_src_configure is run in EAPI >= 2
	case ${EAPI:-0} in
		0|1) ;;
		*) kde_src_configure ;;
	esac
}

# @FUNCTION: kde-meta_src_compile
# @DESCRIPTION:
# Does some checks before it invokes kde_src_compile
kde-meta_src_compile() {
	debug-print-function $FUNCNAME "$@"
	case ${EAPI:-0} in
		0|1) kde-meta_src_configure ;;
	esac
	kde_src_compile "$@"
}

# @FUNCTION: kde-meta_src_install
# @USAGE: [ make ] [ dodoc ] [ all ]
# @DESCRIPTION:
# The kde-meta src_install function
kde-meta_src_install() {
	debug-print-function $FUNCNAME "$@"

	set_common_variables

	if [[ "$1" == "" ]]; then
		kde-meta_src_install make dodoc
	fi
	while [[ -n "$1" ]]; do
		case $1 in
			make)
				for dir in $KMMODULE $KMEXTRA $DOCS; do
					if [[ -d "${S}"/$dir ]]; then
						cd "${S}"/$dir
						emake DESTDIR="${D}" destdir="${D}" install || die "emake install failed."
					fi
				done
				;;
			dodoc)
				kde_src_install dodoc
				;;
			all)
				kde-meta_src_install make dodoc
				;;
		esac
		shift
	done
}

# @FUNCTION: kde-meta_pkg_postinst
# @DESCRIPTION:
# Calls kde_pkg_postinst
kde-meta_pkg_postinst() {
	# Remove dir with KMNAME module info
	#rm -rf ${EGIT_REPO_KMNAME_POOL}
	#unset EGIT_REPO_KMNAME_POOL

	# Call kde method
	kde_pkg_postinst
}

# @FUNCTION: kde-meta_pkg_postrm
# @DESCRIPTION:
# Calls kde_pkg_postrm
kde-meta_pkg_postrm() {
	# Remove dir with KMNAME module info
	#rm -rf ${EGIT_REPO_KMNAME_POOL}
	#unset EGIT_REPO_KMNAME_POOL

	# Call kde method
	kde_pkg_postrm
}

case ${EAPI:-0} in
	0|1) EXPORT_FUNCTIONS src_unpack src_compile src_install pkg_postinst pkg_postrm;;
	2) EXPORT_FUNCTIONS src_unpack src_prepare src_configure src_compile src_install pkg_postinst pkg_postrm;;
esac
