#!/bin/sh
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
    echo "This is a pull request. Just build in DEBUG configuration."
    xctool -workspace $WORKSPACE_NAME.xcworkspace \
    -scheme $SCHEME_NAME -sdk $BUILD_SDK \
    -configuration Debug ONLY_ACTIVE_ARCH=NO
    if [[ $? -ne 0 ]]; then
        echo "Error: Build fail."
        exit 1
    fi

else
    echo "Building..."
    xctool -workspace $WORKSPACE_NAME.xcworkspace \
    -scheme $SCHEME_NAME -sdk $BUILD_SDK ONLY_ACTIVE_ARCH=NO
    if [[ $? -ne 0 ]]; then
        echo "Error: Build fail."
        exit 1
    fi

    echo "Running test..."
    xctool test -workspace $WORKSPACE_NAME.xcworkspace \
    -scheme $SCHEME_NAME -sdk $BUILD_SDK ONLY_ACTIVE_ARCH=NO
    if [[ $? -ne 0 ]]; then
        echo "Error: Test fail."
        exit 1
    fi

    echo "Making archive..."
    xctool -workspace $WORKSPACE_NAME.xcworkspace -scheme $SCHEME_NAME \
    -sdk $RELEASE_BUILD_SDK -configuration Release ONLY_ACTIVE_ARCH=NO \
    archive -archivePath $PWD/build/$APP_NAME.xcarchive
    if [[ $? -ne 0 ]]; then
        echo "Error: Archive fail."
        exit 1
    fi
fi
