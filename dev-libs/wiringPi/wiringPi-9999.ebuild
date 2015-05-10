# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-r3 autotools-utils

DESCRIPTION="GPIO Library for Pi and ODroid"
HOMEPAGE="https://github.com/hardkernel/wiringPi"
EGIT_REPO_URI="https://github.com/tbe/wiringPi"
EGIT_BRANCH="master"

LICENSE="LGPLv3"
SLOT="0"
KEYWORDS="arm"
IUSE="static-libs util doc examples suid"

DEPEND=""
RDEPEND="${DEPEND}"

src_prepare() {
	eautoreconf -i
}

src_configure() {
	local myeconfargs=(
		$(use_enable suid)
		$(use_enable util gpio-tool)
	)
	autotools-utils_src_configure
}

src_install() {
	autotools-utils_src_install

	if use "examples" ; then
		dodir /usr/share/doc/wiringPi/
		cp -R examples ${D}/usr/share/doc/wiringPi/ || die "failed to install examples"
	fi

	if use "doc" ; then dodoc pins/pins.pdf ; fi
}
