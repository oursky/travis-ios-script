#!/bin/sh
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment will be done."
  exit 0
fi

#####################
# Make the ipa file #
#####################
PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"
APP_EXTENSION_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$APP_EXTENSION_PROFILE_NAME.mobileprovision"
WATCH_APP_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$WATCH_APP_PROFILE_NAME.mobileprovision"
WATCH_APP_EXTENSION_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$WATCH_APP_EXTENSION_PROFILE_NAME.mobileprovision"
OUTPUT_DIR="$PWD/build"
ARCHIVE_DIR="$OUTPUT_DIR/$APP_NAME.xcarchive"
APP_FILE_PATH="$ARCHIVE_DIR/Products/Applications/$APP_NAME.app"

if [[ -n "$APP_EXTENSION_PROFILE_NAME" && -n "$WATCH_APP_PROFILE_NAME" ]]; then
  xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_DIR" \
  -exportPath "$OUTPUT_DIR/$APP_NAME.ipa" \
  -exportWithOriginalSigningIdentity

  # xcodebuild -project Extension\ Demo.xcodeproj -scheme Extension\ Demo -sdk iphoneos -archivePath ./Build/extension-demo.xcarchive -configuration AdHoc archive
  # xcodebuild -exportArchive -archivePath ./Build/extension-demo.xcarchive -exportPath ./Build/extension-demo.ipa -exportWithOriginalSigningIdentity


  # xcrun -log -sdk iphoneos \
  # PackageApplication "$APP_FILE_PATH" \
  # -o "$OUTPUT_DIR/$APP_NAME.ipa" \
  # -sign "$DEVELOPER_NAME" \
  # -embed "$PROVISIONING_PROFILE" "$APP_EXTENSION_PROFILE" "$WATCH_APP_PROFILE" "$WATCH_APP_EXTENSION_PROFILE"
elif [[ -n "$APP_EXTENSION_PROFILE_NAME" ]]; then
  xcrun -log -sdk iphoneos \
  PackageApplication "$APP_FILE_PATH" \
  -o "$OUTPUT_DIR/$APP_NAME.ipa" \
  -sign "$DEVELOPER_NAME" \
  -embed "$PROVISIONING_PROFILE" "$APP_EXTENSION_PROFILE"
elif [[ -n "$WATCH_APP_PROFILE_NAME" ]]; then
  xcrun -log -sdk iphoneos \
  PackageApplication "$APP_FILE_PATH" \
  -o "$OUTPUT_DIR/$APP_NAME.ipa" \
  -sign "$DEVELOPER_NAME" \
  -embed "$PROVISIONING_PROFILE" "$WATCH_APP_PROFILE" "$WATCH_APP_EXTENSION_PROFILE"
else
  xcrun -log -sdk iphoneos \
  PackageApplication "$APP_FILE_PATH" \
  -o "$OUTPUT_DIR/$APP_NAME.ipa" \
  -sign "$DEVELOPER_NAME" \
  -embed "$PROVISIONING_PROFILE"
fi

#########################
# Achieve the dSYM file #
#########################
zip -r -9 "$OUTPUT_DIR/$APP_NAME.app.dSYM.zip" "$ARCHIVE_DIR/dSYMs/$APP_NAME.app.dSYM"

RELEASE_DATE=`date '+%Y-%m-%d %H:%M:%S'`
RELEASE_NOTES="Build: $TRAVIS_BUILD_NUMBER\nUploaded: $RELEASE_DATE"

##############################
# Upload to Apple TestFlight #
##############################
if [[ "$TRAVIS_BRANCH" == "$APPLE_TESTFLIGHT_UPLOAD_BRANCH" ]]; then

  # Send to slack first
  # Because pilot upload is not that reliable
  echo 'uploading ipa file to slack'
  curl -i https://slack.com/api/files.upload \
    -X POST \
    -F file=@$OUTPUT_DIR/$APP_NAME.ipa \
    -F channels=C04SDRRGT \
    -F token=$SLACK_API_TOKEN \
    -F filename="$APP_NAME.ipa"

  if [[ -z "$DELIVER_USER" ]]; then
    echo "Error: Missing TestFlight DELIVER_USER."
    exit 1
  fi

  if [[ -z "$DELIVER_PASSWORD" ]]; then
    echo "Error: Missing TestFlight DELIVER_PASSWORD"
    exit 1
  fi

  if [[ -z "$DELIVER_APP_ID" ]]; then
    echo "Error: Missing TestFlight App ID"
    exit 1
  fi

  echo "Installing gem..."
  gem install pilot

  echo "Install timeout"
  brew install coreutils

  echo "At $APPLE_TESTFLIGHT_UPLOAD_BRANCH branch, upload to testflight."
  gtimeout 600 pilot upload --skip_submission --ipa "$OUTPUT_DIR/$APP_NAME.ipa" --apple_id "$DELIVER_APP_ID" --username $DELIVER_USER

  if [[ $? -ne 0 ]]; then
    echo "Error: Fail uploading to TestFlight"
    exit 1
  fi

  if [[ -n "$CRITTERCISM_APP_ID" && -n "$CRITTERCISM_KEY" ]]; then
    curl "https://app.crittercism.com/api_beta/dsym/$CRITTERCISM_APP_ID" \
    -F dsym="@$OUTPUT_DIR/$APP_NAME.app.dSYM.zip" \
    -F key="$CRITTERCISM_KEY"

    if [[ $? -ne 0 ]]; then
      echo "Error: Fail uploading to Crittercism"
      exit 1
    fi
  fi
fi

#######################
# Upload to HockeyApp #
#######################
if [[ "$TRAVIS_BRANCH" == "$HOCKEYAPP_UPLOAD_BRANCH" ]]; then
  if [[ -z "$HOCKEY_APP_ID" ]]; then
    echo "Error: Missing HockeyApp ID"
    exit 1
  fi

  if [[ -z "$HOCKEY_APP_TOKEN" ]]; then
    echo "Error: Missing HockeyApp Token"
    exit 1
  fi

  echo "At $HOCKEYAPP_UPLOAD_BRANCH branch, upload to hockeyapp."
  curl https://rink.hockeyapp.net/api/2/apps/$HOCKEY_APP_ID/app_versions \
    -F status="2" \
    -F notify="0" \
    -F notes="$RELEASE_NOTES" \
    -F notes_type="0" \
    -F ipa="@$OUTPUT_DIR/$APP_NAME.ipa" \
    -H "X-HockeyAppToken: $HOCKEY_APP_TOKEN"

  if [[ $? -ne 0 ]]; then
    echo "Error: Fail uploading to HockeyApp"
    exit 1
  fi

  if [[ -n "$CRITTERCISM_APP_ID" && -n "$CRITTERCISM_KEY" ]]; then
    curl "https://app.crittercism.com/api_beta/dsym/$CRITTERCISM_APP_ID" \
    -F dsym="@$OUTPUT_DIR/$APP_NAME.app.dSYM.zip" \
    -F key="$CRITTERCISM_KEY"

    if [[ $? -ne 0 ]]; then
      echo "Error: Fail uploading to Crittercism"
      exit 1
    fi
  fi
fi
