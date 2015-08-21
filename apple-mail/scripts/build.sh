#!/bin/bash

function check_errors() {
        if [ $1 -ne 0 ]; then
                echo "ERROR. Build process stop"
                exit 1
        fi
}

function prepare() {
	MAIL_BUNDLE_NAME="VirgilSecurityMail"
	MAIL_BUNDLE="${MAIL_BUNDLE_NAME}.mailbundle"
	MAIL_BUNDLE_SYMBOLS="${MAIL_BUNDLE}.dSYM"

	SCRIPT_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	ROOT_FOLDER="${SCRIPT_FOLDER}/.."
	RESULT_FOLDER="${ROOT_FOLDER}/build/Release"
	PKG_PLIST_FILE="${RESULT_FOLDER}/PkgInfo.plist"
	PKG_SCRIPTS_FOLDER="${SCRIPT_FOLDER}/pkg_scripts"
	
	ICON_FILE=""
	PKG_IDENTIFIER=org.virgil.security
	VMIL="0"
	CUR_VERSION="1.0.0"
	
	INSTALL_PATH="Library/Mail/Bundles/"
}

function build_project() {
	xcodebuild -project ${SCRIPT_FOLDER}/../VirgilSecurityMail.xcodeproj -arch x86_64 -configuration Release
	check_errors $?
}

function create_pkg_info_file() {
	echo "-------------- Create PkgInfo file ------------------"
	echo '<?xml version="1.0" encoding="UTF-8"?>' >"${PKG_PLIST_FILE}"
	echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >>"${PKG_PLIST_FILE}"
	echo '<plist version="1.0">' >>"${PKG_PLIST_FILE}"
	echo '<array>' >>"${PKG_PLIST_FILE}"
	echo '        <dict>' >>"${PKG_PLIST_FILE}"
	echo '                <key>BundleIsVersionChecked</key>' >>"${PKG_PLIST_FILE}"
	echo '                <true/>' >>"${PKG_PLIST_FILE}"
	echo '                <key>BundleOverwriteAction</key>' >>"${PKG_PLIST_FILE}"
	echo '                <string>upgrade</string>' >>"${PKG_PLIST_FILE}"
	echo '                <key>RootRelativeBundlePath</key>' >>"${PKG_PLIST_FILE}"
	echo '                <string>'${MAIL_BUNDLE}'</string>' >>"${PKG_PLIST_FILE}"
	echo '        </dict>' >>"${PKG_PLIST_FILE}"
	echo '</array>' >>"${PKG_PLIST_FILE}"
	echo '</plist>' >>"${PKG_PLIST_FILE}"
};

function create_pkg() {
	pushd ${RESULT_FOLDER}
		create_pkg_info_file
		rm -rf ${MAIL_BUNDLE_SYMBOLS}
		pushd ..
			echo "------------- pkgbuild working ... ------------------"
			rm -rf ${MAIL_BUNDLE_SYMBOLS}
			pkgbuild	--root 				./Release/				\
						--component-plist	${PKG_PLIST_FILE}		\
						--scripts 			"${PKG_SCRIPTS_FOLDER}"	\
						--install-location	"${INSTALL_PATH}" 		\
						--identifier		"${PKG_IDENTIFIER}"		\
				${MAIL_BUNDLE_NAME}.pkg
			
			#--version "$VERSION"					\
			check_errors $?
		popd
	popd
}

function build() {
	prepare
	build_project
	create_pkg
}

build