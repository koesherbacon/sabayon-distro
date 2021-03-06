# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils toolchain-funcs xdg-utils

DESCRIPTION="Glib bindings for poppler"
HOMEPAGE="https://poppler.freedesktop.org/"
SRC_URI="https://poppler.freedesktop.org/poppler-${PV}.tar.xz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~arm"
SLOT="0/67"

IUSE="cairo cjk curl cxx debug doc +introspection +jpeg +jpeg2k +lcms nss png tiff +utils"
S="${WORKDIR}/poppler-${PV}"

# No test data provided
RESTRICT="test"

COMMON_DEPEND="
	cairo? (
		dev-libs/glib:2
		>=x11-libs/cairo-1.10.0
		introspection? ( >=dev-libs/gobject-introspection-1.32.1:= )
	)
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	~app-text/poppler-base-${PV}[cjk=,cxx=,jpeg=,jpeg2k=,lcms=,png=,tiff=,utils=,curl=,debug=,doc=,nss=]
"

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

	if ! grep -Fq 'cmake_policy(SET CMP0002 OLD)' CMakeLists.txt ; then
		sed '/^cmake_minimum_required/acmake_policy(SET CMP0002 OLD)' \
			-i CMakeLists.txt || die
	else
		einfo "policy(SET CMP0002 OLD) - workaround can be removed"
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
		-DENABLE_LIBCURL="$(usex curl)"
		-DENABLE_CPP="$(usex cxx)"
		-DENABLE_UTILS="$(usex utils)"
		-DSPLASH_CMYK=OFF
		-DUSE_FIXEDPOINT=OFF
		-DUSE_FLOAT=OFF
		-DWITH_Cairo="$(usex cairo)"
		-DWITH_GObjectIntrospection="$(usex introspection)"
		-DWITH_JPEG="$(usex jpeg)"
		-DWITH_NSS3="$(usex nss)"
		-DWITH_PNG="$(usex png)"
		-DWITH_Qt4=OFF
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Core=ON
		-DWITH_TIFF="$(usex tiff)"
	)
	if use jpeg; then
		mycmakeargs+=(-DENABLE_DCTDECODER=libjpeg)
	else
		mycmakeargs+=(-DENABLE_DCTDECODER=none)
	fi
	if use jpeg2k; then
		mycmakeargs+=(-DENABLE_LIBOPENJPEG=openjpeg2)
	else
		mycmakeargs+=(-DENABLE_LIBOPENJPEG=none)
	fi
	if use lcms; then
		mycmakeargs+=(-DENABLE_CMS=lcms2)
	else
		mycmakeargs+=(-DENABLE_CMS=)
	fi

	cmake-utils_src_configure
}

src_install() {
	pushd "${BUILD_DIR}/glib"
	emake DESTDIR="${ED}" install
	popd

	local utils_destdir=${T}/utils-destdir
	rm -rf "${utils_destdir}" || die
	mkdir "${utils_destdir}" || die

	pushd "${BUILD_DIR}/utils"
	emake DESTDIR="${utils_destdir}" install
	popd

	if use cairo; then
		# Other utils are installed in poppler-base, but that package does not
		# depend on Cairo.
		dobin "${utils_destdir}/usr/bin/pdftocairo"
		doman "${utils_destdir}/usr/share/man/man1/pdftocairo.1"
	fi

	# install pkg-config data
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${BUILD_DIR}"/poppler-glib.pc
	use cairo && doins "${BUILD_DIR}"/poppler-cairo.pc

	# live version doesn't provide html documentation
	if use cairo && use doc && [[ ${PV} != 9999 ]]; then
		# For now install gtk-doc there
		insinto /usr/share/gtk-doc/html/poppler
		doins -r "${S}"/glib/reference/html/*
	fi
}
