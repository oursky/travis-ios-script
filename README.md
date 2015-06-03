Travis iOS Script
=================

Reusable iOS script for Travis CI with Testflight, Crittercism and HockeyApp support

## Prerequisites
1. Travis CLI: `sudo gem install travis`
2. xctool: `brew install xctool`

## Getting started
1. Submodule this repository: `git submodule add git@github.com:oursky/travis-ios-script.git`

2. Export Code Signing Identity certificates.
   1. Open up Keychain Access
   2. Make sure you are under `Login` -> `My Certificates`
   3. Right click on the certificate (Let's say your distribution cert.) -> Export -> choose `.cer` as file format -> save as `dist.cer`
   4. Expand the same certificate. You should see a private key entry. Export it like the previous step but choose `.p12` as file format. Save as `dist.p12`. You will prompted for a password. Generate one and it will be your `KEY_PASSWORD`.

3. Download your app's Provisioning Profile from Apple Developer Member Center.

4. Submodule this repo to your project

5. Execute the script, follow the instructions

6. Push. Sit back. Enjoy a :coffee:.

## Reference
- [Travis CI for iOS](http://www.objc.io/issue-6/travis-ci.html)
