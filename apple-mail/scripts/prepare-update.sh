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
		ls
		zip -r "${ZIP_FILE}" "${MAIL_BUNDLE_NAME}/${MAIL_BUNDLE_NAME}.pkg"
		check_errors $?
		
		echo -e "\n------------------- Sign PKG ------------------------"
		SIGNATURE=$(${OPENSSL} dgst -sha1 -binary < "${ZIP_FILE}" | ${OPENSSL} dgst -dss1 -sign "${PRIVATE_KEY}" | ${OPENSSL} enc -base64)
		echo "SIGNATURE = ${SIGNATURE}"
		
		ZIP_SIZE=$(wc -c ${ZIP_FILE} | awk '{print $1}')
		
		echo -e "\n---------------- Create Appcast ---------------------"
		
		echo "<rss xmlns:sparkle=\"http://www.andymatuschak.org/xml-namespaces/sparkle\"" 						> "${APPCAST_FILE}"
		echo "	xmlns:dc=\"http://purl.org/dc/elements/1.1/\" version=\"2.0\">" 								>> "${APPCAST_FILE}"
		echo "	<channel>" 																						>> "${APPCAST_FILE}"
		echo "		<title>Virgil Security Mail Plugin Changelog</title>" 										>> "${APPCAST_FILE}"
		echo "		<link>" 																					>> "${APPCAST_FILE}"
		echo "			${APPCAST_LINK}" 																		>> "${APPCAST_FILE}"
		echo "		</link>" 																					>> "${APPCAST_FILE}"
		echo "		<description>Most recent changes with links to updates.</description>" 						>> "${APPCAST_FILE}"
		echo "		<language>en</language>" 																	>> "${APPCAST_FILE}"
		echo "		<item>" 																					>> "${APPCAST_FILE}"
		echo "			<title>Version ${CUR_VERSION}</title>" 													>> "${APPCAST_FILE}"
		echo "			<description>" 																			>> "${APPCAST_FILE}"
		echo "				<![CDATA[" 																			>> "${APPCAST_FILE}"
		echo "					<ul> <li>Bugfixes.</li>" 														>> "${APPCAST_FILE}"
		echo "					</ul>" 																			>> "${APPCAST_FILE}"
		echo "				]]>" 																				>> "${APPCAST_FILE}"
		echo "			</description>" 																		>> "${APPCAST_FILE}"
		echo "			<pubDate>$(date "+%a, %d %b %Y %H:%M:%S %Z")</pubDate>" 								>> "${APPCAST_FILE}"
		echo "			<enclosure url=\"${DOWNLOAD_LINK}\"" 													>> "${APPCAST_FILE}"
		echo "			sparkle:version=\"${CUR_VERSION}\" length=\"${ZIP_SIZE}\" type=\"application/octet-stream\"" >> "${APPCAST_FILE}"
		echo "			sparkle:dsaSignature=\"${SIGNATURE}\"/>" 												>> "${APPCAST_FILE}"
		echo "		</item>" 																					>> "${APPCAST_FILE}"
		echo "	</channel>" 																					>> "${APPCAST_FILE}"
		echo "</rss>" 																							>> "${APPCAST_FILE}"
		
		cat "${APPCAST_FILE}"
		
		echo -e "\n-------------- Remove tmp folder --------------------"
		rm -rf "${MAIL_BUNDLE_NAME}"
	popd
	
}

prepare_update