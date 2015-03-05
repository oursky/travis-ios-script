#!/bin/sh
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment will be done."
  exit 0
fi

#####################
# Make the ipa file #
#####################
PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"
OUTPUTDIR="$PWD/build/Release-iphoneos"

if [[ -n "$APP_EXTENSION_PROFILE_NAME" ]]; then
  xcrun -log -sdk iphoneos \
  PackageApplication "$OUTPUTDIR/$APP_NAME.app" \
  -o "$OUTPUTDIR/$APP_NAME.ipa" \
  -sign "$DEVELOPER_NAME" \
  -embed "$PROVISIONING_PROFILE" "$APP_EXTENSION_PROFILE_NAME"
else
  xcrun -log -sdk iphoneos \
  PackageApplication "$OUTPUTDIR/$APP_NAME.app" \
  -o "$OUTPUTDIR/$APP_NAME.ipa" \
  -sign "$DEVELOPER_NAME" \
  -embed "$PROVISIONING_PROFILE"
fi

#########################
# Achieve the dSYM file #
#########################
zip -r -9 "$OUTPUTDIR/$APP_NAME.app.dSYM.zip" "$OUTPUTDIR/$APP_NAME.app.dSYM"

RELEASE_DATE=`date '+%Y-%m-%d %H:%M:%S'`
RELEASE_NOTES="Build: $TRAVIS_BUILD_NUMBER\nUploaded: $RELEASE_DATE"

##############################
# Upload to Apple TestFlight #
##############################
if [[ "$TRAVIS_BRANCH" == "$APPLE_TESTFLIGHT_UPLOAD_BRANCH" ]]; then
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
  gem install deliver

  echo "At $APPLE_TESTFLIGHT_UPLOAD_BRANCH branch, upload to testflight."
  deliver testflight "$OUTPUTDIR/$APP_NAME.ipa" -a "$DELIVER_APP_ID"

  if [[ $? -ne 0 ]]; then
    echo "Error: Fail uploading to TestFlight"
    exit 1
  fi

  if [[ -n "$CRITTERCISM_APP_ID" && -n "$CRITTERCISM_KEY" ]]; then
    curl "https://app.crittercism.com/api_beta/dsym/$CRITTERCISM_APP_ID" \
    -F dsym="@$OUTPUTDIR/$APP_NAME.app.dSYM.zip" \
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
    -F status="1" \
    -F notify="0" \
    -F notes="$RELEASE_NOTES" \
    -F notes_type="0" \
    -F ipa="@$OUTPUTDIR/$APP_NAME.ipa" \
    -H "X-HockeyAppToken: $HOCKEY_APP_TOKEN"

  if [[ $? -ne 0 ]]; then
    echo "Error: Fail uploading to HockeyApp"
    exit 1
  fi

  if [[ -n "$CRITTERCISM_APP_ID" && -n "$CRITTERCISM_KEY" ]]; then
    curl "https://app.crittercism.com/api_beta/dsym/$CRITTERCISM_APP_ID" \
    -F dsym="@$OUTPUTDIR/$APP_NAME.app.dSYM.zip" \
    -F key="$CRITTERCISM_KEY"

    if [[ $? -ne 0 ]]; then
      echo "Error: Fail uploading to Crittercism"
      exit 1
    fi
  fi
fi
