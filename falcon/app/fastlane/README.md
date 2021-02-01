fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios prd
```
fastlane ios prd
```
publish to testflight beta
### ios stg
```
fastlane ios stg
```
publish to testflight staging
### ios dev
```
fastlane ios dev
```
publish to testflight dev
### ios upload_crashlytics
```
fastlane ios upload_crashlytics
```
Upload symbols to crashlytics
### ios regtest
```
fastlane ios regtest
```
set regtest as env
### ios refresh_dsyms
```
fastlane ios refresh_dsyms
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
