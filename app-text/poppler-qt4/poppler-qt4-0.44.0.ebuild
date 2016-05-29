# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

CMAKE_WARN_UNUSED_CLI=1
inherit cmake-utils toolchain-funcs xdg-utils

DESCRIPTION="Qt4 bindings for poppler"
HOMEPAGE="https://poppler.freedesktop.org/"
SRC_URI="https://poppler.freedesktop.org/poppler-${PV}.tar.xz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~arm"
SLOT="0/61"
IUSE="cairo-qt"
S="${WORKDIR}/poppler-${PV}"

# No test data provided
RESTRICT="test"

COMMON_DEPEND="
		dev-qt/qtcore:4
		dev-qt/qtgui:4
		cairo-qt? ( >=x11-libs/cairo-1.10.0 )
"

DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	~app-text/poppler-base-${PV}"

PATCHES=(
	"${FILESDIR}/qt5-dependencies.patch"
	"${FILESDIR}/fix-multilib-configuration.patch"
	"${FILESDIR}/respect-cflags.patch"
	"${FILESDIR}/openjpeg2.patch"
	"${FILESDIR}/FindQt4.patch"
)

src_prepare() {
	cmake-utils_src_prepare

	# Clang doesn't grok this flag, the configure nicely tests that, but
	# cmake just uses it, so remove it if we use clang
	if [[ ${CC} == clang ]] ; then
		sed -i -e 's/-fno-check-new//' cmake/modules/PopplerMacros.cmake || die
	fi

	# Enable experimental patchset for subpixel font rendering using cairo
	# backend for poppler-qt4 from https://github.com/giddie/poppler-qt4-cairo-backend.
	if use cairo-qt; then
		ewarn "Enabling unsupported, experimental cairo-qt patchset. Please do not report bugs."
		epatch "${FILESDIR}/cairo-qt-experimental/0001-Cairo-backend-added-to-Qt4-wrapper.patch"
		epatch "${FILESDIR}/cairo-qt-experimental/0002-Setting-default-Qt4-backend-to-Cairo.patch"
		epatch "${FILESDIR}/cairo-qt-experimental/0003-Forcing-subpixel-rendering-in-Cairo-backend.patch"
		epatch "${FILESDIR}/cairo-qt-experimental/0004-Enabling-slight-hinting-in-Cairo-Backend.patch"
	fi
}

src_configure() {
	xdg_environment_reset
	local mycmakeargs=(
		-DBUILD_GTK_TESTS=OFF
		-DBUILD_QT4_TESTS=OFF
		-DBUILD_QT5_TESTS=OFF
		-DBUILD_CPP_TESTS=OFF
		-DENABLE_SPLASH=ON
		-DENABLE_ZLIB=ON
		-DENABLE_ZLIB_UNCOMPRESS=OFF
		-DENABLE_XPDF_HEADERS=ON
		-DENABLE_LIBCURL=OFF
		-DENABLE_CPP=OFF
		-DENABLE_UTILS=OFF
		-DSPLASH_CMYK=OFF
		-DUSE_FIXEDPOINT=OFF
		-DUSE_FLOAT=OFF
		-DWITH_Cairo=OFF
		-DWITH_GObjectIntrospection=OFF
		-DWITH_JPEG=OFF
		-DWITH_NSS3=OFF
		-DWITH_PNG=OFF
		-DWITH_Qt4=ON
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Core=ON
		-DWITH_TIFF=OFF
		-DENABLE_LIBOPENJPEG=
		-DENABLE_CMS=
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}
