#!/bin/bash

function check_errors() {
        if [ $1 -ne 0 ]; then
                echo "ERROR. Build process stop"
                exit 1
        fi
}

function prepare() {
	MAIL_BUNDLE_NAME="VirgilSecurityMail"

	SCRIPT_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	DMG_PREPARE_FOLDER="${SCRIPT_FOLDER}/../build/DMG"
	
	CUR_VERSION="1.0.0.${BUILD_NUMBER}"
	
	DMG_PACK_FOLDER="${MAIL_BUNDLE_NAME}"
	ZIP_FILE="${MAIL_BUNDLE_NAME}-${CUR_VERSION}.zip"
	BASE_LINK="https://downloads.virgilsecurity.com/updates/apple-mail"
	DOWNLOAD_LINK="${BASE_LINK}/${ZIP_FILE}"
	APPCAST_FILE="virgilmailcast.xml"
	APPCAST_LINK="${BASE_LINK}/${APPCAST_FILE}"
	
	PRIVATE_KEY="/updater_keys/dsa_priv.pem"
	OPENSSL="/usr/bin/openssl"
}

function prepare_update() {
	prepare
	pushd "${DMG_PREPARE_FOLDER}"
		echo -e "\n----------------- Compress PKG ----------------------"
		zip -r "${ZIP_FILE}" "${MAIL_BUNDLE_NAME}.pkg"
		check_errors $?
		
		echo -e "\n------------------- Sign PKG ------------------------"
		SIGNATURE=$(${OPENSSL} dgst -sha1 -binary < "${ZIP_FILE}" | ${OPENSSL} dgst -dss1 -sign "${PRIVATE_KEY}" | ${OPENSSL} enc -base64)
		echo "SIGNATURE = ${SIGNATURE}"
		
		echo -e "\n---------------- Create Appcast ---------------------"
		
		"<rss xmlns:sparkle=\"http://www.andymatuschak.org/xml-namespaces/sparkle\"" 						> "${APPCAST_FILE}"
		"	xmlns:dc=\"http://purl.org/dc/elements/1.1/\" version=\"2.0\">" 								>> "${APPCAST_FILE}"
		"	<channel>" 																						>> "${APPCAST_FILE}"
		"		<title>Virgil Security Mail Plugin Changelog</title>" 										>> "${APPCAST_FILE}"
		"		<link>" 																					>> "${APPCAST_FILE}"
		"			${APPCAST_LINK}" 																		>> "${APPCAST_FILE}"
		"		</link>" 																					>> "${APPCAST_FILE}"
		"		<description>Most recent changes with links to updates.</description>" 						>> "${APPCAST_FILE}"
		"		<language>en</language>" 																	>> "${APPCAST_FILE}"
		"		<item>" 																					>> "${APPCAST_FILE}"
		"			<title>Version 2.0</title>" 															>> "${APPCAST_FILE}"
		"			<description>" 																			>> "${APPCAST_FILE}"
		"				<![CDATA[" 																			>> "${APPCAST_FILE}"
		"					<ul> <li>Bugfixes.</li>" 														>> "${APPCAST_FILE}"
		"					</ul>" 																			>> "${APPCAST_FILE}"
		"				]]>" 																				>> "${APPCAST_FILE}"
		"			</description>" 																		>> "${APPCAST_FILE}"
		"			<pubDate>$(date "+%a, %d %b %Y %H:%M:%S %Z")</pubDate>" 								>> "${APPCAST_FILE}"
		"			<enclosure url=\"${ZIP_FILE}\"" 														>> "${APPCAST_FILE}"
		"			sparkle:version=\"2.0\" length=\"107758\" type=\"application/octet-stream\"" 			>> "${APPCAST_FILE}"
		"			sparkle:dsaSignature=\"${SIGNATURE}\"/>" 												>> "${APPCAST_FILE}"
		"		</item>" 																					>> "${APPCAST_FILE}"
		"	</channel>" 																					>> "${APPCAST_FILE}"
		"</rss>" 																							>> "${APPCAST_FILE}"
		
		echo -e "\n-------------- Remove tmp folder --------------------"
		rm -rf "${MAIL_BUNDLE_NAME}"
	popd
	
}

prepare_update