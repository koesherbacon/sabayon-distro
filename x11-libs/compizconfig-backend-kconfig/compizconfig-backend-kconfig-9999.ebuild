# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde git autotools

EGIT_REPO_URI="git://anongit.opencompositing.org/fusion/compizconfig/${PN}"

DESCRIPTION="Compizconfig Kconfig Backend (git)"
HOMEPAGE="http://opencompositing.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="~x11-libs/libcompizconfig-${PV}"

S="${WORKDIR}/${PN}"

pkg_postinst() {
	kde_pkg_postinst
	echo

	ewarn "DO NOT report bugs to Gentoo's bugzilla"
	einfo "Please report all bugs to nesl247@gmail.com"
	einfo "Thank you on behalf of the Gentoo Xeffects team"
}
