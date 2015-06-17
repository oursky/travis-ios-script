language: objective-c
cache: cocoapods
before_install:
- export LANG=en_US.UTF-8
- brew update
- gem install --no-rdoc --no-ri cocoapods
before_script:
- ./scripts/init-config.sh
- ./scripts/decrypt-key.sh
- ./scripts/add-key.sh
script:
- ./scripts/build-test-archive.sh
after_success:
- ./scripts/sign-and-upload.sh
after_script:
- ./scripts/remove-key.sh
notifications:
  slack: # slack notification key
env:
  global:
  - APP_NAME="${app_name}"
  - DEVELOPER_NAME="${developer_name}"
  - PROFILE_NAME="${profile_name}"
  - WORKSPACE_NAME="${workspace_name}"
  - SCHEME_NAME="${scheme_name}"
  - BUILD_SDK="iphonesimulator8.1"
  - RELEASE_BUILD_SDK="iphoneos8.1"
  - DELIVER_USER="${deliver_user}"
  - DELIVER_APP_ID="${deliver_app_id}"
  - APP_EXTENSION_PROFILE_NAME="${app_extension_profile_name}"
  - APPLE_TESTFLIGHT_UPLOAD_BRANCH="${apple_testflight_upload_branch}"
  - HOCKEYAPP_UPLOAD_BRANCH="${hockeyapp_upload_branch}"
  - secure: ${encryption_secret} # ENCRYPTION_SECRET
  - secure: ${hockey_app_id} # HOCKEY_APP_ID
  - secure: ${hockey_app_token} # HOCKEY_APP_TOKEN
  - secure: ${crittercism_app_id} # CRITTERCISM_APP_ID
  - secure: ${crittercism_key} # CRITTERCISM_KEY
  - secure: ${key_password} # KEY_PASSWORD
