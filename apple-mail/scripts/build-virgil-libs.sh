#!/bin/bash

function check_errors() {
        if [ $1 -ne 0 ]; then
                echo "ERROR. Build process stop"
                exit 1
        fi
}

function prepare() {
	SCRIPT_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	ROOT_FOLDER="${SCRIPT_FOLDER}/.."
	BUILD_FOLDER="${ROOT_FOLDER}/build"
	VIRGIL_CPP_PATH="${ROOT_FOLDER}/virgil-cpp"
	
	#RESULT_FOLDER="${BUILD_FOLDER}/Release"
}

function recreate_folder() {
	if [ -d ${1} ]; then
		rm -rf ${1}
	fi
	mkdir ${1}
}

function copy_files_by_mask() {
	find "${1}" -name "${2}" -exec cp {} "${3}" \;
}

function build_virgil_libs() {
	pushd "${VIRGIL_CPP_PATH}"
		BUILD_FOLDER="build"
		recreate_folder ${BUILD_FOLDER}
		pushd ${BUILD_FOLDER}
			echo -e "\n------------ Build virgil libraries -----------------"
			cmake ../virgil.sdk.keys
			check_errors $?
			
			make
			check_errors $?
			
			echo -e "\n-------- Move results to external folder ------------"
			RESULT_FOLDER="${ROOT_FOLDER}/virgil-libs"
			RESULT_INCLUDE_FOLDER="${RESULT_FOLDER}/include"
			RESULT_LIB_FOLDER="${RESULT_FOLDER}/lib/"
			recreate_folder ${RESULT_FOLDER}
			mkdir "${RESULT_INCLUDE_FOLDER}"
			mkdir "${RESULT_LIB_FOLDER}"
			
			copy_files_by_mask "./" "*.a" "${RESULT_LIB_FOLDER}"
			cp -rf "../virgil.sdk.keys/include/" "${RESULT_INCLUDE_FOLDER}"
			
			copy_files_by_mask "ext/virgil.crypto/lib/" "*.a" "${RESULT_LIB_FOLDER}"
			cp -rf "ext/virgil.crypto/include/" "${RESULT_INCLUDE_FOLDER}"
			
			move_files_by_mask "rest/bin/" "*.a" "${RESULT_LIB_FOLDER}"
		popd
		
		echo -e "\n------------- Delete build artifacts ----------------"
		rm -rf ${BUILD_FOLDER}
	popd
}

function build() {
	prepare
	build_virgil_libs
}

build