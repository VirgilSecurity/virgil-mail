#!/bin/bash

function make_dmg() {
	ARG_DIR="${1}"
	ARG_SRC_DIR_NAME="${2}"
	ARG_IMG_FOLDER="${3}"
	ARG_ICON="${4}"
	ARG_BACKGROUND="${5}"
	ARG_DMG_NAME="${6}"
	ARG_VOL_NAME="${7}"
	ARG_TMP_DIR="./tmp"

	SRC_DIR_NAME="${ARG_SRC_DIR_NAME}"
	echo "SRC_DIR_NAME=${SRC_DIR_NAME}";
	
	if [ ! -e "${ARG_DIR}"/"${SRC_DIR_NAME}" ]; then
		echo "Error! Bundle \"${SRC_DIR_NAME}\" does not exist!"
		exit 1
	fi

	TARGET_DIR=${ARG_DIR}
	echo "TARGET_DIR=$TARGET_DIR";

	if [ ! "${TARGET_DIR}" ]; then
		TARGET_DIR=`pwd`
	fi

	if [ ! -e "${TARGET_DIR}" ]; then
		echo "Error! Directory \"${TARGET_DIR}\" does not exist."
		exit 1
	fi

	cd "${TARGET_DIR}"

	TMP_DIR=${ARG_TMP_DIR}
	echo "TMP_DIR=$TMP_DIR";

	VOL_NAME=${ARG_VOL_NAME}
	echo "VOL_NAME=$VOL_NAME";

	if [ ! "${VOL_NAME}" ]; then
		VOL_NAME=${SRC_DIR_NAME%.*}
		echo "Defaulting dmg volume name to ${VOL_NAME}"
	fi


	BG_IMG_NAME=${ARG_BACKGROUND}
	echo "BG_IMG_NAME=$BG_IMG_NAME";
	VOL_ICON_NAME=${ARG_ICON}
	echo "VOL_ICON_NAME=$VOL_ICON_NAME";

	DMG_NAME_TMP="${ARG_DIR}"/"${SRC_DIR_NAME%.*}_tmp.dmg"
	echo "DMG_NAME_TMP=$DMG_NAME_TMP";

	if [ "${ARG_DMG_NAME}" ]; then
		DMG_NAME_BASE=${ARG_DMG_NAME}
	else
		DMG_NAME_BASE=${SRC_DIR_NAME%.*}
	fi

	DMG_NAME="${DMG_NAME_BASE}.dmg"
	echo "DMG_NAME=$DMG_NAME";

	echo -n "*** Copying content of ${SRC_DIR_NAME} to the temporary dir... "
	mkdir "$TMP_DIR"
	cp -R "${ARG_DIR}"/"${SRC_DIR_NAME}/" ${TMP_DIR}/
	echo "done!"

	echo -n "*** Unmount disk image with same name if present..."
	MOUNTED_VOLUME="/Volumes/${VOL_NAME}"
	if [ -e "${MOUNTED_VOLUME}" ]; then
		echo "Present volume with same name. Unmount ..."
		hdiutil detach -force "${MOUNTED_VOLUME}"
	fi

	echo -n "*** Creating temporary dmg disk image..."
	rm -f "${DMG_NAME_TMP}"
	hdiutil create -ov -srcfolder $TMP_DIR -format UDRW -volname "${VOL_NAME}" "${DMG_NAME_TMP}"

	echo -n "*** Mounting temporary image... "
	device=$(hdiutil attach -readwrite -noverify -noautoopen "${DMG_NAME_TMP}" | egrep '^/dev/' | sed 1q | awk '{print $1}')
	echo "done! (device ${device})"

	echo -n "*** Sleeping for 5 seconds..."
	sleep 5
	echo " done!"

	echo "*** Setting style for temporary dmg image..."


	if [ "${ARG_BACKGROUND}" ]; then
		echo -n "    * Copying background image... "
	
		BG_FOLDER="/Volumes/${VOL_NAME}/.background"
		mkdir "${BG_FOLDER}"
		IMG_TO_COPY="${ARG_IMG_FOLDER}"/"${BG_IMG_NAME}"
		cp "${IMG_TO_COPY}" "${BG_FOLDER}/"
		
		DS_STORE="${ARG_IMG_FOLDER}"/_DS_Store
		perl -pe "s/1.0.0.101/${CUR_VERSION}/g" < "${DS_STORE}" > "/Volumes/${VOL_NAME}/.DS_Store"
		
		echo "done!"
		NO_BG=
	else
		NO_BG="-- "
	fi
	
	if [ "${ARG_APP_FOLDER_ICON}" ]; then
		echo -n "    * Copying /Applications image... "
	
		APPLICATIONS_ICO_FOLDER="/Volumes/${VOL_NAME}/.ico"
		mkdir "${APPLICATIONS_ICO_FOLDER}"
		APP_FOLDER_ICON_TO_COPY="${ARG_IMG_FOLDER}"/"${ARG_APP_FOLDER_ICON}"
		cp "${APP_FOLDER_ICON_TO_COPY}" "${APPLICATIONS_ICO_FOLDER}/.ApplicationsIcon.icns"

		echo "done!"
		NO_APP_FOLDER_ICON=
	else
		NO_APP_FOLDER_ICON="-- "
	fi

	if [ "${ARG_ICON}" ]; then
		echo -n "    * Copying volume icon... "

		VOL_ICON_NAME="${ARG_IMG_FOLDER}"/volume.icns
		ICON_FOLDER="/Volumes/${VOL_NAME}"
		cp "${VOL_ICON_NAME}" "${ICON_FOLDER}/.VolumeIcon.icns"

		echo "done!"

		echo -n "    * Setting volume icon... "

		SetFile -c icnC "${ICON_FOLDER}/.VolumeIcon.icns"
		SetFile -a C "${ICON_FOLDER}"

		echo "done!"
	fi

	echo "done!"

	echo "*** Converting tempoprary dmg image in compressed readonly final image... "
	echo "    * Changing mode and syncing..."
	chmod -Rf go-w /Volumes/"${VOL_NAME}"
	sync
	sync
	echo "    * Detaching ${device}..."
	hdiutil detach -force ${device}
	rm -f ${DMG_NAME}
	echo "    * Converting..."
	hdiutil convert "${DMG_NAME_TMP}" -format UDZO -imagekey zlib-level=9 -o "${DMG_NAME}"
	echo "done!"

	echo -n "*** Removing temporary image... "
	rm -f "${DMG_NAME_TMP}"
	echo "done!"

	echo -n "*** Cleaning up temp folder... "
	rm -rf $TMP_DIR
	echo "done!"

	echo "
	*** Everything done. DMG disk image is ready for distribution.
	"
	
	exit 0
}
