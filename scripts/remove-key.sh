#!/bin/sh
security delete-keychain ios-build.keychain
rm -f "~/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"
if [[ -n "$APP_EXTENSION_PROFILE_NAME" ]]; then
	rm -f "~/Library/MobileDevice/Provisioning Profiles/$APP_EXTENSION_PROFILE_NAME.mobileprovision"
  rm "profile/$APP_EXTENSION_PROFILE_NAME.mobileprovision"
fi

rm "profile/$PROFILE_NAME.mobileprovision"
rm "certs/dist.cer"
rm "certs/dist.p12"
