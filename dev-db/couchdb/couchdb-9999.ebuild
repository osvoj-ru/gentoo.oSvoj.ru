# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils multilib pax-utils user systemd git-r3

DESCRIPTION="Distributed, fault-tolerant and schema-free document-oriented database"
HOMEPAGE="https://couchdb.apache.org/"
#SRC_URI="https://github.com/apache/couchdb/archive/master.zip"


EGIT_REPO_URI="https://github.com/apache/couchdb.git"
EGIT_BRANCH="master" # todo: package the golang version




LICENSE="Apache-2.0"
SLOT="3.0"
KEYWORDS="amd64 ppc x86"
IUSE="libressl selinux test"

RDEPEND=">=dev-libs/icu-4.3.1:=
		>=dev-lang/erlang-19[ssl]
		~dev-lang/spidermonkey-1.8.5
		!libressl? ( dev-libs/openssl:0 )
		libressl? ( dev-libs/libressl )
		net-misc/curl
		dev-python/sphinx
		selinux? ( sec-policy/selinux-couchdb )
		sys-process/psmisc
"

DEPEND="${RDEPEND}
		>=dev-util/rebar-2.6.0
		<dev-util/rebar-3.0.0
		sys-devel/autoconf-archive
"

RESTRICT=test

S="${WORKDIR}/${P}"

pkg_setup() {
    einfo "start setup ===================================================================="
	enewgroup couchdb
	enewuser couchdb -1 -1 /var/lib/couchdb couchdb
	#./configure  --with-curl --erlang-md5
   einfo "end setup ------------------------------------------------------------------------------------------------------------"
}
src_unpack() {
    einfo "start unpack =================================================================================="
	einfo $(pwd)
	git clone -b $EGIT_BRANCH --progress $EGIT_REPO_URI ${S}
	einfo ${A}
	cd ${S}
    ./configure  --with-curl --erlang-md5
    einfo "${S}"
	make -j1 release
	einfo "end unpack ------------------------------------------------------------------------------------"
}



src_prepare() {
	#./configure  --with-curl --erlang-md5
	true;
}

src_configure() {
	#econf \
	#	--with-erlang "${EPREFIX}"/usr/$(get_libdir)/erlang/usr/include \
	#	--with-curl \
	#	--erlang-md5 \
	#	--skip-deps \
	#	--rebar /usr/bin/rebar \
	#	--user=couchdb
	echo $(pwd)
	true;
	einfo "start configure ===================================================================="
	#./configure  --with-curl --erlang-md5
	einfo "end configure ---------------------------------------------------------------------------"
}

src_compile() {
	#emake release
	true;
}

src_test() {
	emake distcheck
}

src_install() {
    einfo "start install ================================================================================="
	mkdir -p "${D}"/opt
	# mv "${S}/rel/couchdb/etc" "${D}/etc/couchdb"
	mv "${S}/rel/couchdb" "${D}/opt/"
	#dosym "../opt/couchdb/etc" "${D}/etc/couchdb"
	#dosym ../../etc/couchdb /opt/couchdb/etc

	keepdir /var/l{ib,og}/couchdb

	fowners couchdb:couchdb \
		/var/lib/couchdb \
		/var/log/couchdb

	for f in "${D}"/opt/couchdb/etc/*.d; do
		fowners root:couchdb "${f#${ED}}"
		fperms 0750 "${f#${ED}}"
	done
	for f in "${D}"/opt/couchdb/etc/*.ini; do
		fowners root:couchdb "${f#${ED}}"
		fperms 0440 "${f#${ED}}"
	done
	# couchdb needs to write to local.ini on first start
	fowners couchdb:couchdb "/opt/couchdb/etc/local.ini"
	fperms  0640 "/opt/couchdb/etc/local.ini"

	insinto /etc/couchdb/default.d
	insopts -m0640 -oroot -gcouchdb
	doins "${FILESDIR}/10_gentoo.ini"

	insinto /etc/logrotate.d/
	newins "${FILESDIR}/${PN}.logrotate" "${PN}"

	newinitd "${FILESDIR}/${PN}.init" "${PN}"
	newconfd "${FILESDIR}/${PN}.conf" "${PN}"
	einfo "${FILESDIR}/${PN}.conf" 
	einfo "${FILESDIR}/${PN}.service"


#    systemd_newunit "${FILESDIR}/${PN}.conf"  "${FILESDIR}/${PN}.service"

	rm "${ED}/opt/couchdb/bin/couchdb.cmd"

	# bug 442616
	pax-mark mr "${D}/opt/couchdb/bin/couchjs"
	pax-mark mr "${D}/opt/couchdb/lib/couch-${PV}/priv/couchjs"
	einfo "end install -----------------------------------------------------------------------------------------"
}

pkg_postinst() {
    einfo "postinstall start ============================================================================================================="
    ewarn "Post install start === "
	true;
	einfo "post install end ---------------------------------------------------------------------------------------------------------------"
}
