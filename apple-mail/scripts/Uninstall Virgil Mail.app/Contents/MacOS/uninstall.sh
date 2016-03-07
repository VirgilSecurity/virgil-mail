#!/bin/bash

if [[ $UID -ne 0 ]] ;then
	bundle="${0%/*}/../.."
	
	escape_filed_path=$(echo $0 | sed "s/ /\\\\\\\\ /g")
	
	osascript -e '
	set bndl to POSIX file "'"$bundle"'"
	set question to localized string "Do you want to remove Virgil Securyty plugin ?" in bundle bndl
	set cancel to localized string "Cancel" in bundle bndl
	set uninstall to localized string "Uninstall" in bundle bndl
	activate
	display dialog question buttons {cancel, uninstall} default button uninstall
	do shell script "'"$escape_filed_path"'" with administrator privileges
	set succeeded to localized string "Virgil Security plugin was removed successfuly" in bundle bndl
	set ok to localized string "OK" in bundle bndl
	activate
	display dialog succeeded buttons {ok} default button ok
	'
	exit
fi

echo "Remove Virgil Security plugin ..."
rm -rf /Library/Mail/Bundles/VirgilSecurityMail.mailbundle

# Remove updater job
UPDATER_PLIST="/Library/LaunchAgents/org.virgilsecurity.mail.update.plist"
UPDATER_JOB_LABEL="org.virgilsecurity.mail.update"
if [ -f "${UPDATER_PLIST}" ]; then
	sudo -u "${USER}" launchctl unload -w "${UPDATER_PLIST}" 2>/dev/null
	launchctl unload -w "${UPDATER_PLIST}" 2>/dev/null
	
	sleep 3
	
	sudo -u "$USER" launchctl remove "${UPDATER_JOB_LABEL}" 2>/dev/null
	sudo launchctl remove "${UPDATER_JOB_LABEL}" 2>/dev/null
fi
rm "${UPDATER_PLIST}" 

ps -xo command -u "$USER" | grep -q '/\Mail.app/' || exit 0

echo "Restart Mail.app ..."

killall Mail
osascript -e "tell application \"/Applications/Mail.app\" to activate"


exit 0
