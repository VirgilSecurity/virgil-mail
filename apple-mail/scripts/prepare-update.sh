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
	
	#TODO: Try to remove it
	BUNDLE_VERSION="1.0.0"
	
	DMG_PACK_FOLDER="${MAIL_BUNDLE_NAME}"
	
	if [ "$RELEASE_TYPE" == "night_build" ]; then
		# TODO: Add night builds
		BASE_LINK="https://downloads.virgilsecurity.com/updates/apple-mail"
		APPCAST_FILE="virgilmailcast.xml"
		RELEASE_NOTES_FILE="release-notes.html"
		ZIP_FILE="${MAIL_BUNDLE_NAME}-${CUR_VERSION}.zip"
	else
		BASE_LINK="https://downloads.virgilsecurity.com/updates/apple-mail"
		APPCAST_FILE="virgilmailcast.xml"
		RELEASE_NOTES_FILE="release-notes.html"
		ZIP_FILE="${MAIL_BUNDLE_NAME}-${CUR_VERSION}.zip"
	fi
	
	SPARKLE_ICON_FILE="icon_128x128.png"
	
	APPCAST_LINK="${BASE_LINK}/${APPCAST_FILE}"
	RELEASE_NOTES_LINK="${BASE_LINK}/${RELEASE_NOTES_FILE}"
	DOWNLOAD_LINK="${BASE_LINK}/${ZIP_FILE}"
	SPARKLE_ICON_LINK="${BASE_LINK}/${RELEASE_NOTES_FILE}"
	RELEASE_NOTES_SRC="${DMG_PREPARE_FOLDER}/../../VirgilSecurityMail/Resources/${RELEASE_NOTES_FILE}"
	SPARKLE_ICON_SRC="${DMG_PREPARE_FOLDER}/../../VirgilSecurityMail/Resources/${SPARKLE_ICON_FILE}"
	
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
		
		echo -e "\n-------------- Copy release notes -------------------"
		echo "-> ${RELEASE_NOTES_FILE}"
		cp "${RELEASE_NOTES_SRC}" "${RELEASE_NOTES_FILE}"
		check_errors $?
		
		echo -e "\n----------- Copy sparkle image file -----------------"
		echo "-> ${SPARKLE_ICON_FILE}"
		cp "${SPARKLE_ICON_SRC}" "${SPARKLE_ICON_FILE}"
		check_errors $?
		
		echo -e "\n---------------- Create Appcast ---------------------"
		
		echo "<rss xmlns:sparkle=\"http://www.andymatuschak.org/xml-namespaces/sparkle\"" 						> "${APPCAST_FILE}"
		echo "	xmlns:dc=\"http://purl.org/dc/elements/1.1/\" version=\"2.0\">" 								>> "${APPCAST_FILE}"
		echo "	<channel>" 																						>> "${APPCAST_FILE}"
		echo "		<title>Virgil Security Mail Plugin Changelog</title>" 										>> "${APPCAST_FILE}"
		echo "		<link>" 																					>> "${APPCAST_FILE}"
		echo "			${APPCAST_LINK}" 																		>> "${APPCAST_FILE}"
		echo "		</link>" 																					>> "${APPCAST_FILE}"
		echo "		<description>Release Notes for the latest versions of</description>" 						>> "${APPCAST_FILE}"
		echo "		<language>en</language>" 																	>> "${APPCAST_FILE}"
		echo "		<image>"																					>> "${APPCAST_FILE}"
		echo "			<url>"																					>> "${APPCAST_FILE}"
		echo "				${SPARKLE_ICON_LINK}"																>> "${APPCAST_FILE}"
		echo "			</url>"																					>> "${APPCAST_FILE}"
		echo "		</image>"																					>> "${APPCAST_FILE}"
		echo "		<item>" 																					>> "${APPCAST_FILE}"
		echo "			<title>Virgil Security Mail ${CUR_VERSION}</title>" 									>> "${APPCAST_FILE}"
		echo "			<sparkle:releaseNotesLink>"																>> "${APPCAST_FILE}"
		echo "				${RELEASE_NOTES_LINK}"																>> "${APPCAST_FILE}"
		echo "			</sparkle:releaseNotesLink>"															>> "${APPCAST_FILE}"
		echo "			<sparkle:minimumSystemVersion>10.10</sparkle:minimumSystemVersion>"						>> "${APPCAST_FILE}"
		echo "			<pubDate>$(date "+%a, %d %b %Y %H:%M:%S %Z")</pubDate>" 								>> "${APPCAST_FILE}"
		echo "			<enclosure url=\"${DOWNLOAD_LINK}\"" 													>> "${APPCAST_FILE}"
		echo "			sparkle:version=\"${BUNDLE_VERSION}\""													>> "${APPCAST_FILE}"
		echo "			sparkle:shortVersionString=\"${CUR_VERSION}\"" 											>> "${APPCAST_FILE}"
		echo "			length=\"${ZIP_SIZE}\""																	>> "${APPCAST_FILE}"
		echo "			type=\"application/octet-stream\""														>> "${APPCAST_FILE}"
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