#!/bin/bash

# Correct plist uuid's
plistMail="/Applications/Mail.app/Contents/Info"
plistFramework="/System/Library/Frameworks/Message.framework/Resources/Info"
plistBundle="/Library/Mail/Bundles/VirgilSecurityMail.mailbundle/Contents/Info"

uuid1=$(defaults read "$plistMail" "PluginCompatibilityUUID")
uuid2=$(defaults read "$plistFramework" "PluginCompatibilityUUID")

if [[ -n "$uuid1" ]] && ! grep -q $uuid1 "${plistBundle}.plist" ;then
        defaults write "$plistBundle" "SupportedPluginCompatibilityUUIDs" -array-add "$uuid1"
fi
if [[ -n "$uuid2" ]] && ! grep -q $uuid2 "${plistBundle}.plist" ;then
        defaults write "$plistBundle" "SupportedPluginCompatibilityUUIDs" -array-add "$uuid2"
fi

plutil -convert xml1 "$plistBundle.plist"
chmod +r "$plistBundle.plist"