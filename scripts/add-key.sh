#!/bin/sh
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
    echo "It is a pull request, skip to add keys..."
    exit 0
fi

if [[ -z "$KEY_PASSWORD" ]]; then
    echo "Error: Missing password for adding private key"
    exit 1
fi

security create-keychain -p travis ios-build.keychain

security default-keychain -s ios-build.keychain

security unlock-keychain -p travis ios-build.keychain

security import ./certs/apple.cer \
-k ~/Library/Keychains/ios-build.keychain \
-T /usr/bin/codesign

security import ./certs/dist.cer \
-k ~/Library/Keychains/ios-build.keychain \
-T /usr/bin/codesign

security import ./certs/dist.p12 \
-k ~/Library/Keychains/ios-build.keychain \
-P $KEY_PASSWORD \
-T /usr/bin/codesign

security set-keychain-settings -t 3600 \
-l ~/Library/Keychains/ios-build.keychain

# See https://docs.travis-ci.com/user/common-build-problems/#Mac%3A-macOS-Sierra-(10.12)-Code-Signing-Errors
security set-key-partition-list -S apple-tool:,apple: -s -k travis ios-build.keychain

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

cp "./profile/$PROFILE_NAME.mobileprovision" ~/Library/MobileDevice/Provisioning\ Profiles/
if [[ -n "$APP_EXTENSION_PROFILE_NAME" ]]; then
	echo "found APP_EXTENSION_PROFILE_NAME"
	cp "./profile/$APP_EXTENSION_PROFILE_NAME.mobileprovision" ~/Library/MobileDevice/Provisioning\ Profiles/
fi
