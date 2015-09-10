#!/bin/bash

function check_errors() {
        if [ $1 -ne 0 ]; then
                echo "ERROR. Build process stop"
                exit 1
        fi
}

function prepare() {
	MAIL_BUNDLE_NAME="VirgilSecurityMail"
	export MAIL_BUNDLE="${MAIL_BUNDLE_NAME}.mailbundle"
	MAIL_BUNDLE_SYMBOLS="${MAIL_BUNDLE}.dSYM"

	SCRIPT_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	ROOT_FOLDER="${SCRIPT_FOLDER}/.."
	BUILD_FOLDER="${ROOT_FOLDER}/build"
	RESULT_FOLDER="${BUILD_FOLDER}/Release"
	PKG_PLIST_FILE="${RESULT_FOLDER}/PkgInfo.plist"
	PKG_SCRIPTS_FOLDER="${SCRIPT_FOLDER}/pkg_scripts"
	
	DMG_PREPARE_FOLDER="${BUILD_FOLDER}/DMG"
	
	CUR_VERSION="1.0.0.${BUILD_NUMBER}"
	
	DMG_PACK_FOLDER="${MAIL_BUNDLE_NAME}"
	
	IMAGES_FOLDER=""
	ICON_FILE=""
	BACKGROUND_FILE=""
	PKG_IDENTIFIER="com.virgilsecurity.app.mail"
	
	INSTALL_PATH="Library/Mail/Bundles/"
	
	UNINSTALL_APP_NAME="Uninstall.app"
	UNINSTALL_APP="${SCRIPT_FOLDER}/${UNINSTALL_APP_NAME}"

	# App certificates
	codesign_cetificate="Developer ID Application: Virgil Security, Inc. (JWNLQ3HC5A)"
	codesign_cetificate_installer="Developer ID Installer: Virgil Security, Inc. (JWNLQ3HC5A)"
	entitlements="/tmp/MacSandbox-Entitlements.plist"
}

function build_project() {
	echo -e "\n------------------ XCode build ----------------------"
	xcodebuild -project ${SCRIPT_FOLDER}/../VirgilSecurityMail.xcodeproj -arch x86_64 -configuration Release
	check_errors $?
}

function create_pkg_info_file() {
	echo -e "\n-------------- Create PkgInfo file ------------------"
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

function create_entitlements_info_file() {
	echo '  <?xml version="1.0" encoding="UTF-8"?>' > "${entitlements}"
	echo '  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> "${entitlements}"
	echo '  <plist version="1.0">' >> "${entitlements}"
	echo '  	<dict>' >> "${entitlements}"
	echo '  		<key>com.apple.security.app-sandbox</key>   <false/>' >> "${entitlements}"
	echo '  	</dict>' >> "${entitlements}"
	echo '  </plist>' >> "${entitlements}"
};

function create_pkg() {
	pushd ${RESULT_FOLDER}
		create_pkg_info_file
		rm -rf ${MAIL_BUNDLE_SYMBOLS}
		pushd ..
			echo -e "\n---------------- Create PKG file --------------------"
			rm -rf ${MAIL_BUNDLE_SYMBOLS}
			pkgbuild	--root 				./Release/							\
						--component-plist	${PKG_PLIST_FILE}					\
						--scripts 			"${PKG_SCRIPTS_FOLDER}"				\
						--install-location	"${INSTALL_PATH}" 					\
						--identifier		"${PKG_IDENTIFIER}"					\
						--version			"${CUR_VERSION}"					\
						--sign				"${codesign_cetificate_installer}"	\
						--timestamp												\
				${MAIL_BUNDLE_NAME}.pkg
			
			check_errors $?
		popd
	popd
}

function create_dmg() {
	echo -e "\n---------------- Create DMG file --------------------"
	source ${SCRIPT_FOLDER}/make-dmg.sh

	echo "Prepare folder for dmg creation ..."
	rm -rf "${DMG_PREPARE_FOLDER}"
	mkdir "${DMG_PREPARE_FOLDER}"
	mkdir "${DMG_PREPARE_FOLDER}/${DMG_PACK_FOLDER}"
	check_errors $?
	
	echo "Move content to dmg folder ..."
	mv "${BUILD_FOLDER}/${MAIL_BUNDLE_NAME}.pkg" "${DMG_PREPARE_FOLDER}/${DMG_PACK_FOLDER}/"
	cp -rf "${UNINSTALL_APP}" "${DMG_PREPARE_FOLDER}/${DMG_PACK_FOLDER}/"
	check_errors $?

	create_entitlements_info_file;
	UNINSTALL_APP_PATH="${DMG_PREPARE_FOLDER}/${DMG_PACK_FOLDER}/${UNINSTALL_APP_NAME}"
	codesign --deep -f -v --entitlements "${entitlements}" -s "$codesign_cetificate" "${UNINSTALL_APP_PATH}"
	check_errors $?
	
	codesign -vvvv "${UNINSTALL_APP_PATH}"
	
	echo "Make dmg ..."
	
#	ARG_DIR="${1}"
#	ARG_APP_BUNDLE_NAME="${2}"
#	ARG_IMG_FOLDER="${3}"
#	ARG_ICON="${4}"
#	ARG_BACKGROUND="${5}"
#	ARG_DMG_NAME="${6}"
#	ARG_VOL_NAME="${7}"
#	ARG_TMP_DIR="./tmp"
	
	DMG_RESULT="$DMG_PREPARE_FOLDER/${MAIL_BUNDLE_NAME}-${CUR_VERSION}"
	make_dmg 	"${DMG_PREPARE_FOLDER}"				\
				"${DMG_PACK_FOLDER}" 				\
				"${IMAGES_FOLDER}" 					\
				"${ICON_FILE}" 						\
				"${BACKGROUND_FILE}" 				\
				"${DMG_RESULT}" 					\
				"${MAIL_BUNDLE_NAME} $CUR_VERSION"
	check_errors $?
};

function build() {
	prepare
	build_project
	create_pkg
	create_dmg
}

build