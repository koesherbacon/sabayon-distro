# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Simple passphrase entry dialogs which utilize the Assuan protocol (meta package)"
HOMEPAGE="http://gnupg.org/aegypten2/index.html"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm ~amd64 ~x86"
# ncurses and emacs use flags are fake, used to mimic portage ebuild USE flags
IUSE="emacs gtk ncurses qt4 qt5 caps gnome-keyring static"

RDEPEND="
	~app-crypt/pinentry-base-${PV}
	caps? ( ~app-crypt/pinentry-base-${PV}[caps] )
	gnome-keyring? ( ~app-crypt/pinentry-gnome-${PV} )
	gtk? ( ~app-crypt/pinentry-gtk2-${PV} )
	qt4? ( ~app-crypt/pinentry-qt4-${PV} )
	qt5? ( ~app-crypt/pinentry-qt5-${PV} )
	static? ( ~app-crypt/pinentry-base-${PV}[static] )"
DEPEND=""

REQUIRED_USE="
	|| ( ncurses gtk qt4 qt5 )
	gtk? ( !static )
	qt4? ( !static )
	qt5? ( !static )
	static? ( ncurses )
	?? ( qt4 qt5 )
"
