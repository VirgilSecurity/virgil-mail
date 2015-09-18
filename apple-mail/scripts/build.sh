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
	
	if [ -d "${BUILD_FOLDER}" ]; then
		rm -rf "${BUILD_FOLDER}"
	fi
	
	RESULT_FOLDER="${BUILD_FOLDER}/Release"
	PKG_PLIST_FILE="${RESULT_FOLDER}/PkgInfo.plist"
	PKG_SCRIPTS_FOLDER="${SCRIPT_FOLDER}/pkg_scripts"
	PKG_NAME="Install Virgil Mail.pkg"
	
	DMG_PREPARE_FOLDER="${BUILD_FOLDER}/DMG"
	
	export BUNDLE_SHORT_VERSION="1.0.0"
	export BUNDLE_VERSION="${BUNDLE_SHORT_VERSION}.${BUILD_NUMBER}"
	
	export CUR_VERSION="${BUNDLE_VERSION}"
	
	DMG_PACK_FOLDER="${MAIL_BUNDLE_NAME}"
	
	IMAGES_FOLDER="${SCRIPT_FOLDER}/pkg_resources"
	ICON_FILE=""
	BACKGROUND_FILE="Installer-Background.png"
	PKG_IDENTIFIER="com.virgilsecurity.app.mail"
	DISTRIBUTION_XML="/tmp/distribution.xml"
	PKG_BACKGROUND_FILE="background.png"
	PKG_WELCOME_FILE="welcome.html"
	PKG_LICENSE_FILE="license.html"
	PKG_ICON="Install.png"
	
	INSTALL_PATH="Library/Mail/Bundles/"
	
	UNINSTALL_APP_NAME="Uninstall Virgil Mail.app"
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

function create_distribution_xml() {
	echo -e "\n------------ Create distribution.xml ----------------"
	echo '<?xml version="1.0" encoding="utf-8" standalone="yes"?>'  							> "${DISTRIBUTION_XML}"
	echo '<installer-gui-script minSpecVersion="1">'  											>> "${DISTRIBUTION_XML}"
	echo '    <title>Virgil Security Mail</title>'  											>> "${DISTRIBUTION_XML}"
	echo '    <organization>'${PKG_IDENTIFIER}'</organization>'  								>> "${DISTRIBUTION_XML}"
	echo '    <domains enable_localSystem="true"/>'  											>> "${DISTRIBUTION_XML}"
	echo '    <options customize="never" require-scripts="false" rootVolumeOnly="true" />'		>> "${DISTRIBUTION_XML}"
	echo '	<allowed-os-versions>'  															>> "${DISTRIBUTION_XML}"
	echo '	    <os-version min="10.10" />'  													>> "${DISTRIBUTION_XML}"
	echo '	</allowed-os-versions>'  															>> "${DISTRIBUTION_XML}"
	echo '	<choices-outline>'  																>> "${DISTRIBUTION_XML}"
	echo '    <line choice="default">'  														>> "${DISTRIBUTION_XML}"
	echo '      <line choice="'${PKG_IDENTIFIER}'"/>'  											>> "${DISTRIBUTION_XML}"
	echo '    </line>'  																		>> "${DISTRIBUTION_XML}"
	echo '  </choices-outline>'  																>> "${DISTRIBUTION_XML}"
    echo '  <choice id="default"/>'																>> "${DISTRIBUTION_XML}"
    echo '  <choice id="'${PKG_IDENTIFIER}'" visible="false">'									>> "${DISTRIBUTION_XML}"
    echo '      <pkg-ref id="'${PKG_IDENTIFIER}'"/>'											>> "${DISTRIBUTION_XML}"
    echo '  </choice>'																			>> "${DISTRIBUTION_XML}"
	echo '	<background file="'${PKG_BACKGROUND_FILE}'" scaling="none" alignment="bottomleft"/>'>> "${DISTRIBUTION_XML}"
	echo '    <welcome    file="'${PKG_WELCOME_FILE}'"    mime-type="text/html" />'  			>> "${DISTRIBUTION_XML}"
	echo '    <license    file="'${PKG_LICENSE_FILE}'"    mime-type="text/html" />'  			>> "${DISTRIBUTION_XML}"
	echo '    <pkg-ref id="'${PKG_IDENTIFIER}'" version="'${CUR_VERSION}'"  onConclusion="none">tmp-Install%20Virgil%20Mail.pkg</pkg-ref>'	>> "${DISTRIBUTION_XML}"
	echo '</installer-gui-script>'  															>> "${DISTRIBUTION_XML}"
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

function hideExtention() {
	SetFile -a E "${1}"
}

function setIcon() {
	local ICON_FOLDER="${1}"
	local ICON_FILE="${2}"
	local FILE_TO_APPLY="${3}"
	
	pushd "${ICON_FOLDER}"
		local TMP_RESOURCE="tmpicns.rsrc"
		
		sips -i "${ICON_FILE}"
		
		# Extract the icon to its own resource file:
		DeRez -only icns "${ICON_FILE}" > "${TMP_RESOURCE}"

		# append this resource to the file you want to icon-ize.
		Rez -append "${TMP_RESOURCE}" -o "${FILE_TO_APPLY}"

		# Use the resource to set the icon.
		SetFile -a C "${FILE_TO_APPLY}"

		rm "${TMP_RESOURCE}"
	popd
}

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
				"tmp-${PKG_NAME}"
			
			check_errors $?
			
			create_distribution_xml;
			
			echo -e "\n-------------- Build product file -------------------"
			
			productbuild --distribution "${DISTRIBUTION_XML}"	\
			--resources "${IMAGES_FOLDER}" 						\
			--package-path .									\
			--version "${CUR_VERSION}" 							\
			--sign "${codesign_cetificate_installer}" 			\
			"${PKG_NAME}"
			
			check_errors $?
			
			#hideExtention "${PKG_NAME}"
			#setIcon "${IMAGES_FOLDER}" "${PKG_ICON}" "${BUILD_FOLDER}/${PKG_NAME}"
			
			#check_errors $?
			
			rm "tmp-${PKG_NAME}"
			
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
	mv "${BUILD_FOLDER}/${PKG_NAME}" "${DMG_PREPARE_FOLDER}/${DMG_PACK_FOLDER}/"
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
#	ARG_VERSION="${8}"
#	ARG_TMP_DIR="./tmp"
	
	DMG_RESULT="$DMG_PREPARE_FOLDER/${MAIL_BUNDLE_NAME}-${CUR_VERSION}"
	make_dmg 	"${DMG_PREPARE_FOLDER}"				\
				"${DMG_PACK_FOLDER}" 				\
				"${IMAGES_FOLDER}" 					\
				"${ICON_FILE}" 						\
				"${BACKGROUND_FILE}" 				\
				"${DMG_RESULT}" 					\
				"${MAIL_BUNDLE_NAME} $CUR_VERSION"	\
				"$CUR_VERSION"
	check_errors $?
};

function build() {
	prepare
	build_project
	create_pkg
	create_dmg
}

build