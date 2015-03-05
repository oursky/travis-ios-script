#!/bin/sh

# setup default upload branch name
if [[ -z "$APPLE_TESTFLIGHT_UPLOAD_BRANCH" ]]; then
  APPLE_TESTFLIGHT_UPLOAD_BRANCH="testflight"
fi

if [[ -z "$APPLE_TESTFLIGHT_UPLOAD_BRANCH" ]]; then
  HOCKEYAPP_UPLOAD_BRANCH="hockeyapp"
fi
