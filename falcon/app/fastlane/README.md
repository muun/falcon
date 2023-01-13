fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios prd

```sh
[bundle exec] fastlane ios prd
```

publish to testflight beta

### ios internalPrd

```sh
[bundle exec] fastlane ios internalPrd
```

publish an internal build pointing to prod by default to testflight. 
  If you want to change the env create a new lane

### ios dev

```sh
[bundle exec] fastlane ios dev
```

publish to testflight dev

### ios upload_crashlytics

```sh
[bundle exec] fastlane ios upload_crashlytics
```

Upload symbols to crashlytics

### ios regtest

```sh
[bundle exec] fastlane ios regtest
```

set regtest as env

### ios refresh_dsyms

```sh
[bundle exec] fastlane ios refresh_dsyms
```



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
