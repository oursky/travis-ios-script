#!/bin/sh
security delete-keychain ios-build.keychain
rm -f "~/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"
if [[  ! -z "$APP_EXTENSION_PROFILE_NAME" ]]; then
	rm -f "~/Library/MobileDevice/Provisioning Profiles/$APP_EXTENSION_PROFILE_NAME.mobileprovision"
fi