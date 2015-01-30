Travis iOS Script
=================

Reusable iOS script for Travis CI with Testflight, Crittercism and HockeyApp support

## Setup
1. Install travis CLI if needed: `sudo gem install travis`
2. Install xctool if needed: `brew install xctool`
3. Copy "_travis.yml.sample" file to ".travis.yml"
4. Fill in necessary info. on ".travis.yml":
    - App Name
    - Developer Name
    - Provision Profile Name
    - Project Workspace Name
    - Scheme Name
    - [Slack Integration](https://slack.com/integrations) Key
5. Add **Travis secure environment variable** by
    `travis encrypt "VariableName=VariableValue" --add`

## Usage
- Place all encrypted cert and private key in **cert** directory
    - `openssl aes-256-cbc -k "<ENCRYPTION_SECRET>" -in dist.cer -out ./certs/dist.cer.enc -a`
    - `openssl aes-256-cbc -k "<ENCRYPTION_SECRET>" -in dist.p12 -out ./certs/dist.p12.enc -a`
- Place all encrypted provision profile in **profile** directory
    - `openssl aes-256-cbc -k "<ENCRYPTION_SECRET>" -in <PROFILE_NAME>.mobileprovision -out ./profile/<PROFILE_NAME>.mobileprovision.enc -a`
- Add encryption secret key:
    - `travis encrypt "ENCRYPTION_SECRET=<Encryption Secret Key>" --add`
- Add protection password for private key:
    - `travis encrypt "KEY_PASSWORD=<Protection Password>" --add`
- Enable uploading **master** branch to [Testflight](https://www.testflightapp.com) by adding API token, Team token and Distribution List:
    - `travis encrypt "TESTFLIGHT_API_TOKEN=<API Token>" --add`
    - `travis encrypt "TESTFLIGHT_TEAM_TOKEN=<Team Token>" --add`
    - `travis encrypt "TESTFLIGHT_DIS_LIST=<Distribution List>" --add`
- Enable uploading dSYM file on **master** branch to [Crittercism](https://www.crittercism.com) by adding App ID and API Key:
    - `travis encrypt "CRITTERCISM_APP_ID=<App ID>" --add`
    - `travis encrypt "CRITTERCISM_KEY=<API Key>" --add`
- Enable uploading **hockeyapp** branch to [HockeyApp](http://hockeyapp.net) by adding App ID and App Token:
    - `travis encrypt "HOCKEY_APP_ID=<App ID>" --add`
    - `travis encrypt "HOCKEY_APP_TOKEN=<App Token>" --add`

## Reference
- [Travis CI for iOS](http://www.objc.io/issue-6/travis-ci.html)
