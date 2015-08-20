#!/bin/bash

function check_errors() {
        if [ $1 -ne 0 ]; then
                echo "ERROR. Build process stop"
                exit 1
        fi
}

function prepare() {
	SCRIPT_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
}

function build_project() {
	xcodebuild -project ${SCRIPT_FOLDER}/libyuv.xcodeproj -arch x86_64 -configuration Debug #Release
	check_errors
}

function build() {
	prepare
	build_project
}

build