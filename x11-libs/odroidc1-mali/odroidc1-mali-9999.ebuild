EAPI=6

inherit git-r3

EGIT_REPO_URI="git://github.com/mdrjr/c1_mali_libs.git"

DESCRIPTION="Closed source drivers for Mali-400 Odroid-C1"
HOMEPAGE="https://github.com/mdrjr/c1_mali_libs.git"

SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="
	>=app-eselect/eselect-opengl-1.2.6"
#RDEPEND="${DEPEND}
#	media-libs/mesa[gles1,gles2]"

PATCHES=(	"${FILESDIR}/0001-Fix-Makefiles.patch"
			"${FILESDIR}/pkgconfig.patch" )

src_prepare() {
	default
}

src_compile() {
	touch .gles-only
}

src_install() {
	local opengl_imp="mali"
	local opengl_dir="/usr/$(get_libdir)/opengl/${opengl_imp}"
	local fbdev_imp="mali"
	local fbdev_dir="/usr/$(get_libdir)/fbdev/${fbdev_imp}"
	
	dodir "${opengl_dir}/lib" "${opengl_dir}/include" "${opengl_dir}/extensions"
	dodir "${fbdev_dir}/lib" "${fbdev_dir}/include" "${fbdev_dir}/extensions"

	emake "libdir=${D}/${opengl_dir}/lib" "includedir=${D}/${opengl_dir}/include" -C x11 install
	emake "libdir=${D}/${fbdev_dir}/lib" "includedir=${D}/${fbdev_dir}/include" -C fbdev install

	# create symlink to libMali and libUMP into /usr/lib
	dosym "opengl/${opengl_imp}/lib/libMali.so" "/usr/$(get_libdir)/libMali.so"
        dosym "opengl/${opengl_imp}/lib/libUMP.so" "/usr/$(get_libdir)/libUMP.so"

	# udev rules to get the right ownership/permission for /dev/ump and /dev/mali
	insinto /lib/udev/rules.d
	doins "${FILESDIR}"/99-mali-drivers.rules

	insinto "${opengl_dir}"
	doins .gles-only
	
	# copy pkgconfig files
	insinto /usr/lib/opengl/mali/pkgconfig
	doins pkgconfig/*
	
	dodir /etc/env.d
	echo -e "PKG_CONFIG_PATH=/usr/lib/opengl/mali/pkgconfig" > \
				"${D}"/etc/env.d/05mali-libs
}

pkg_postinst() {
	elog "You must be in the video group to use the Mali 3D acceleration."
	elog
	elog "To use the Mali OpenGL ES libraries, run \"eselect opengl set mali\""
}

pkg_prerm() {
	"${ROOT}"/usr/bin/eselect opengl set --use-old --ignore-missing xorg-x11
}

pkg_postrm() {
	"${ROOT}"/usr/bin/eselect opengl set --use-old --ignore-missing xorg-x11
}
