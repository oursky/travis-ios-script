Travis iOS Script
=================

Reusable iOS script for Travis CI with Testflight, Crittercism and HockeyApp support

## Prerequisites
1. Travis CLI: `sudo gem install travis`
2. xctool: `brew install xctool`

## Getting started
1. Submodule this repository: `git submodule add git@github.com:oursky/travis-ios-script.git`
2. Copy the sample `_travis.yml.sample` as `.travis.yml` to the root of your repository.
3. Modify the paths of scripts so that it points to the submodule. (e.g. `./scripts/init-config.sh` -> `./travis-ios-script/scripts/init-config.sh`)
4. Make two directories on the project root:
   ```
   mkdir certs
   mkdir profile
   ```

5. Decide on a `ENCRYPTION_SECRET` to be used for encryption of your certificates.
   * Add it to travis: `travis encrypt "ENCRYPTION_SECRET=<Encryption Secret Key>" --add`

6. Export Code Signing Identity certificates.
   1. Open up Keychain Access
   2. Make sure you are under `Login` -> `My Certificates`
   3. Right click on the certificate (Let's say your distribution cert.) -> Export -> choose `.cer` as file format -> save as `dist.cer`
   4. Expand the same certificate. You should see a private key entry. Export it like the previous step but choose `.p12` as file format. Save as `dist.p12`. You will prompted for a password. Generate one and it will be your `KEY_PASSWORD`.
   5. Add the private key password to travis: `travis encrypt "KEY_PASSWORD=<Protection Password>" --add`
   6. Encrypt the exported certificate and private key using `ENCRYPTION_SECRET`:
      ```
      openssl aes-256-cbc -k "<ENCRYPTION_SECRET>" -in dist.cer -out ./certs/dist.cer.enc -a
      openssl aes-256-cbc -k "<ENCRYPTION_SECRET>" -in dist.p12 -out ./certs/dist.p12.enc -a
      ```

7. Download your app's Provisioning Profile from Apple Developer Member Center. Encrypt it:
   ```
   openssl aes-256-cbc -k "<ENCRYPTION_SECRET>" -in <PROFILE_NAME>.mobileprovision -out ./profile/<PROFILE_NAME>.mobileprovision.enc -a
   ```

8. Fill in the necessary info. on ".travis.yml":
   - `APP_NAME`: The name of your app. Easy!
   - `DEVELOPER_NAME`: The Code Signing Identity in Xcode.
   - `PROFILE_NAME`: The file name of the downloaded Provisioning Profile without the extension.
   - `WORKSPACE_NAME`: `(THIS_IS_YOUR_WORKSPACE_NAME).xcworkspace`
   - `SCHEME_NAME`:
     1. Open Xcode -> Product -> Scheme -> Manage Scheme...
     2. A window will pop up. It is usually the name of the first item.

9. Push. Sit back. Enjoy a :coffee:.

## Hey, do you provide integration of XXX?

### Testflight

Let's say you are to upload build to Testflight whenever you push to branch `master`:

1. Add the environment variable `APPLE_TESTFLIGHT_UPLOAD_BRANCH="master"` in `.travis.yml`.
2. Add Testflight Apple ID and App ID as environment variables in `.travis.yml` respectively:
   ```
   DELIVER_USER="<Apple ID>"
   DELIVER_APP_ID="App ID"
   ```

3. Add you Testflight password securely: `travis encrypt "DELIVER_PASSWORD=<Password>" --add`
4. :coffee:

### HockeyApp

Let's say you are to upload build to HockeyApp whenever you push to branch `master`:

1. Add the environment variable `HOCKEYAPP_UPLOAD_BRANCH="master"` in `.travis.yml`.
2. Add App ID and Token securely:
   ```
   travis encrypt "HOCKEY_APP_ID=<App ID>" --add
   travis encrypt "HOCKEY_APP_TOKEN=<App Token>" --add
   ```

3. :tea:

### Crittercism

Upload dSYM to Crittercism:

1. Add App ID and API Key securely:
   ```
   travis encrypt "CRITTERCISM_APP_ID=<App ID>" --add
   travis encrypt "CRITTERCISM_KEY=<API Key>" --add
   ```

2. :sake:

## Reference
- [Travis CI for iOS](http://www.objc.io/issue-6/travis-ci.html)
