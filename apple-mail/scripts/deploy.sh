#!/bin/bash

appname="VirgilSecurity Plugin"
appfile=VirgilSecurityPlugin

scriptfolder=""
pkg_full_name=$scriptfolder/$appfile

appfolder=$tmp_folder/$appname.app

contextfolder="$appfolder/Contents"
macosfolder="$contextfolder/MacOS"
frameworksfolder="$contextfolder/Frameworks"
resourcesfolder="$contextfolder/Resources"
plistfile="$contextfolder/Info.plist"
entitlements="$tmp_folder/MacSandbox-Entitlements.plist"
imagesfolder="$scriptfolder/${PLATFORM_DIR_PREFIX}/pictures/"

# AppStore certificates
#codesign_cetificate=""
#codesign_cetificate_installer=""

# App certificates
#codesign_cetificate=""
#codesign_cetificate_installer=""

icofile=ico.icns
volume_icofile=volume.icns
applications_icofile=app_folder.icns
background=background.png
install_path=/Applications
package_path=$tmp_folder

bundle_dmg=$appname.dmg
pkg_dmg=pkg.dmg

bundle_dentifier=org.virgil.security

CUR_VERSION="1.0.0"
CUR_RC="RC01"

function create_version_strings() {
	CUR_VERSION=$VMAH.$VMAL.$VMIH
	CUR_FULL_VERSION=$VMAH.$VMAL.$VMIH.$VMIL
	CUR_BUILD="b"
	if (($VMIL < 10))
	then
		CUR_BUILD=$CUR_BUILD"0"	
	fi
	CUR_BUILD=$CUR_BUILD"$VMIL"	
};

function preparation() {
	if ! [ -e $pkg_full_name ]
	then
  		echo "ERROR: $pkg_full_name does not exist"
  		exit 1
		elif [ -e "$appfolder" ]
	then
  		echo "$appfolder already exists, deleting ..."
  		rm -rf "$appfolder"
	fi
};

function create_bundle_folders() {
	echo "$ECHO_SUFFIX Make bundle folders $ECHO_SUFFIX"
	echo $appfolder
	mkdir "$appfolder"
	
	echo "-------"
	
	mkdir "$contextfolder"
	echo $contextfolder
	
	mkdir "$macosfolder"
	echo $macosfolder
	
	mkdir "$frameworksfolder"
	echo $frameworksfolder
	
	mkdir "$resourcesfolder"
	echo $resourcesfolder
};
  
function copy_elements() {
	echo "$ECHO_SUFFIX Copy files to bundle $ECHO_SUFFIX"
	cp      $pkg_full_name "$macosfolder"/"$appname"
	cp      $imagesfolder/$icofile  "$resourcesfolder"

	if [ $EXTERNAL_RESOURCES == "true" ]; then
		for i in $(find "${tmp_folder}" -type f | grep .rcc); do
			cp "${i}" "${resourcesfolder}/"
		done;
	fi

};

function create_pkg_info_file() {
	echo "$ECHO_SUFFIX Create plist file for pkg $ECHO_SUFFIX"
	echo "-------------- Create PkgInfo file ------------------"
	echo $PkgInfoContents >"$appfolder"/Contents/PkgInfo
	echo '<?xml version="1.0" encoding="UTF-8"?>' >"$plistfile"
	echo '<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >>"$plistfile"
	echo '<plist version="1.0">' >>"$plistfile"
	echo '<dict>' >>"$plistfile"	
	
	echo '  <key>LSApplicationCategoryType</key>' >>"$plistfile"
	echo '  <string>public.app-category.social-networking</string>' >>"$plistfile"
	
	echo '  <key>CFBundleDevelopmentRegion</key>' >>"$plistfile"
	echo '  <string>English</string>' >>"$plistfile"
	
	echo '  <key>CFBundleExecutable</key>' >>"$plistfile"
	echo '  <string>'$appname'</string>' >>"$plistfile"
	
	echo '  <key>CFBundleIconFile</key>' >>"$plistfile"
	echo '  <string>'$icofile'</string>' >>"$plistfile"
	san
	echo '  <key>CFBundleIdentifier</key>' >>"$plistfile"
	echo '  <string>'$bundle_dentifier'</string>' >>"$plistfile"
	
	echo '  <key>CFBundleInfoDictionaryVersion</key>' >>"$plistfile"
	echo '  <string>6.0</string>' >>"$plistfile"
	
	echo '  <key>CFBundlePackageType</key>' >>"$plistfile"
	echo '  <string>APPL</string>' >>"$plistfile"
	
	echo '  <key>CFBundleSignature</key>' >>"$plistfile"
	echo '  <string>MAG#</string>' >>"$plistfile"
	
	echo '  <key>CFBundleVersion</key>' >>"$plistfile"
	echo '  <string>'$VMIL'</string>' >>"$plistfile"
	
	echo '  <key>CFBundleShortVersionString</key>' >>"$plistfile"
	echo '  <string>'$CUR_VERSION'</string>' >>"$plistfile"
	
	echo '  <key>NSPrincipalClass</key>' >>"$plistfile"
	echo '  <string>NSApplication</string>' >>"$plistfile"
	
	echo '  <key>NSHighResolutionCapable</key>' >>"$plistfile"
	echo '  <string>True</string>' >>"$plistfile"
	
	echo '  <key>CFBundleURLTypes</key>' >>"$plistfile"
	echo '  <array>' >>"$plistfile"
	echo '  	<dict>' >>"$plistfile"

	echo '  		<key>CFBundleURLName</key>' >>"$plistfile"
	echo "  		<string>${appname}</string>" >>"$plistfile"

	echo '  	</dict>' >>"$plistfile"
	echo '  </array>' >>"$plistfile"
	
	echo '</dict>' >>"$plistfile"
	echo '</plist>'>>"$plistfile"
};

function create_entitlements_info_file() {
	echo '  <?xml version="1.0" encoding="UTF-8"?>' >> "$entitlements"
	echo '  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> "$entitlements"
	echo '  <plist version="1.0">' >> "$entitlements"
	echo '  	<dict>' >> "$entitlements"
	#echo '  		<key>com.apple.security.app-sandbox</key>   <true/>' >> "$entitlements"
	echo '  		<key>com.apple.security.app-sandbox</key>   <false/>' >> "$entitlements"
	
	echo '  		<key>com.apple.security.device.camera</key>   <true/>' >> "$entitlements"
	echo '  		<key>com.apple.security.device.microphone</key>   <true/>' >> "$entitlements"
	echo '  		<key>com.apple.security.network.client</key>   <true/>' >> "$entitlements"
	echo '  		<key>com.apple.security.network.server</key>   <true/>' >> "$entitlements"
	echo '  		<key>com.apple.security.files.user-selected.read-write</key>   <true/>' >> "$entitlements"

	echo '			<key>com.apple.security.scripting-targets</key>' >> "$entitlements"
        echo '			<dict>' >> "$entitlements"
        echo '    			<key>com.apple.preference</key>' >> "$entitlements"
        echo '    			<array>' >> "$entitlements"
        echo '        				<string>com.apple.systemevents</string>' >> "$entitlements"
        echo '    			</array>' >> "$entitlements"
        echo '			</dict>' >> "$entitlements"

    	echo '			<key>com.apple.security.temporary-exception.apple-events</key>' >> "$entitlements"
        echo '			<array>' >> "$entitlements"
        echo '   			<string>com.apple.systemevents</string>' >> "$entitlements"
       	echo ' 			</array>' >> "$entitlements"

	echo '  		<key>com.apple.security.application-groups</key>' >>"$entitlements"
	echo '  		<array>' >>"$entitlements"
	echo '  			<string>G39BQY9ZQ8.tc_client</string>' >>"$entitlements"
	echo '  		</array>' >>"$entitlements"
	echo '  	</dict>' >> "$entitlements"
	echo '  </plist>' >> "$entitlements"
};

function add_own_plugins() {
	gui_plugins_folder="${contextfolder}/PlugIns/gui"
	mkdir "${gui_plugins_folder}"
	cp "${tmp_folder}/${OSX_NOTIFICATION_PLUGIN_NAME}" "${gui_plugins_folder}/"
}

function sign_files() {
	pushd "$1"
		find * -type f | while read j; do
			echo "$j"
			codesign -f -v -s "$codesign_cetificate" "$j"
		done
	popd
};

function create_dmg() {
	
	echo "$ECHO_SUFFIX Create dmg $ECHO_SUFFIX"
	source $script_folder/helpers/make_dmg.sh

	mkdir $package_path

	echo "Bundle dmg $bundle_dmg ..."
	
#	ARG_DIR="$1"
#	ARG_ICON="$2"
#	ARG_BACKGROUND="$3"
#	ARG_COORDS="$4"	
#	ARG_SIZE="$5"
#	ARG_DMG_NAME="$6"
#	ARG_VOL_NAME="$7"
#	ARG_TMP_DIR="./tmp"
#	ARG_ADD_VERSION="$8"
#	ARG_CODESIGN_ID="$9"	
	
	echo "$ECHO_SUFFIX codesign $ECHO_SUFFIX"
	security unlock-keychain -p 12345 "/Users/builder/Library/Keychains/login.keychain"

	#  Set env variable path to correct codesign_allocate 
	XCODE_PATH_CONTENT_DEVELOPER=$(xcode-select -print-path)
	echo "XCODE_PATH_CONTENT_DEVELOPER = ${XCODE_PATH_CONTENT_DEVELOPER}"
	if [ -f "${XCODE_PATH_CONTENT_DEVELOPER}/usr/bin/codesign_allocate" ]; then
  		export CODESIGN_ALLOCATE="${XCODE_PATH_CONTENT_DEVELOPER}/usr/bin/codesign_allocate"
	elif [ -f "${XCODE_PATH_CONTENT_DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate" ]; then
  		export CODESIGN_ALLOCATE="${XCODE_PATH_CONTENT_DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate"
	else
  		export CODESIGN_ALLOCATE="/usr/bin/codesign_allocate"
	fi
	echo "CODESIGN_ALLOCATE = ${CODESIGN_ALLOCATE}"
	#~Set env variable path to correct codesign_allocate

	sign_files "${appfolder}/Contents/Frameworks/"
	sign_files "${appfolder}/Contents/PlugIns/"

	codesign --deep -f -v --entitlements "$entitlements" -s "$codesign_cetificate" "${appfolder}"
	echo "$ECHO_SUFFIX codesign done $ECHO_SUFFIX"
	
	echo "$ECHO_SUFFIX Build package for AppStore $ECHO_SUFFIX"
	productbuild --component "${appfolder}" /Applications --sign "${codesign_cetificate_installer}" "${package_path}/${appname}.pkg"
	echo "$ECHO_SUFFIX Build package for AppStore done $ECHO_SUFFIX"
	
	dmg="$package_path"/"$appname"
	make_dmg "${tmp_folder}" "${appname}".app "${imagesfolder}" "${icofile}" "${background}" "${applications_icofile}" "430:360:210:360" "640:480"  "$dmg" "$appname $CUR_VERSION"  ""  ""
};

function clear_tmp() {
	echo "$ECHO_SUFFIX Clear temp folder $ECHO_SUFFIX"
	#rm -rf $tmp_folder
};

function copy_result_files() {
	echo "$ECHO_SUFFIX Copy result files $ECHO_SUFFIX"
	source $script_folder/helpers/dir_tree_control.sh
	
	copy_file_to_dir_tree "$package_path" "$bundle_dmg"
	copy_file_to_dir_tree "$package_path" "${appname}.pkg"
};

function deploy() {
	create_version_strings;
	preparation;
	create_bundle_folders;
	copy_elements;
	create_pkg_info_file;
	create_entitlements_info_file;
	create_dmg;
	copy_result_files;
	clear_tmp;
};

