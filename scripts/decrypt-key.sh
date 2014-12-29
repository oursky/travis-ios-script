#!/bin/sh

if [[ -z "$ENCRYPTION_SECRET" ]]; then
    echo "Error: Missing encryption secret."
    exit 1
fi

if [[ -z "$PROFILE_NAME" ]]; then
    echo "Error: Missing provision profile name"
    exit 1
fi

if [[ ! -e "profile/$PROFILE_NAME.mobileprovision.enc" ]]; then
    echo "Error: Missing encrypted provision profile"
    exit 1
fi

if [[ ! -e "certs/dist.cer.enc" ]]; then
    echo "Error: Missing encrypted distribution cert."
    exit 1
fi

if [[ ! -e "certs/dist.p12.enc" ]]; then
    echo "Error: Missing encrypted private key."
    exit 1
fi

openssl aes-256-cbc \
-k "$ENCRYPTION_SECRET" \
-in "profile/$PROFILE_NAME.mobileprovision.enc" -d -a \
-out "profile/$PROFILE_NAME.mobileprovision"

openssl aes-256-cbc \
-k "$ENCRYPTION_SECRET" \
-in "certs/dist.cer.enc" -d -a \
-out "certs/dist.cer"

openssl aes-256-cbc \
-k "$ENCRYPTION_SECRET" \
-in "certs/dist.p12.enc" -d -a \
-out "certs/dist.p12"
