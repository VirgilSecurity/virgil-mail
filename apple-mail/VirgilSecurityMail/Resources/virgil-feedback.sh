#!/bin/bash

function prepare {
	WORK_DIR="/tmp/virgil_work"
	
	LOGS_SRC_DIR="${HOME}/Library/Containers/com.apple.mail/Data/Library/Caches/"
	LOG_CURRENT="virgilsecurity.log"
	LOG_PREV="prev_virgilsecurity.log"
	
	#TODO: Remove this
	SYSTEM_LOG="/var/log/system.log"
	
	INFO_ATTACHMENT="${WORK_DIR}/info.tar.gz"
	
	if [ -d "${WORK_DIR}" ]; then
		rm -rf "${WORK_DIR}"
	fi
	mkdir "${WORK_DIR}"
}

function createArchive {
	pushd "${WORK_DIR}"
		CONTENT_DIR="info"
		mkdir "${CONTENT_DIR}"
		pushd "${CONTENT_DIR}"
			cp "${LOGS_SRC_DIR}/${LOG_CURRENT}" .
			cp "${LOGS_SRC_DIR}/${LOG_PREV}" .
			cp "${SYSTEM_LOG}" .
		popd
		tar -zcvf "${INFO_ATTACHMENT}" "${CONTENT_DIR}"/
	popd
}

function prepareEmail {
	echo
	osascript <<EOD
	set theSubject to "Virgil Mail User Feedback"
	set theBody to "Place your text here ..."
	set theAddress to "vrg1817@mail.ru"
	set theAttachment1 to "${INFO_ATTACHMENT}"
	set theSender to "Some Sender"
	tell application "Mail"
		activate
		set theNewMessage to make new outgoing message with properties {subject:theSubject, content:theBody & return & return, visible:true}
		tell theNewMessage
			set visibile to true
			make new to recipient at end of to recipients with properties {address:theAddress}
			try
				make new attachment with properties {file name:theAttachment1} at after the last word of the last paragraph
				set message_attachment to 0
				on error errmess -- oops
				log errmess -- log the error
				set message_attachment to 1
			end try
			activate
		end tell
		activate
	end tell
EOD
}

function createFeedback {
	prepare
	createArchive
	prepareEmail
}

createFeedback
