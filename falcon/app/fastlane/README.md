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

### ios export_prod_ipa

```sh
[bundle exec] fastlane ios export_prod_ipa
```

Export an IPA pointing to prod env

### ios dogfood

```sh
[bundle exec] fastlane ios dogfood
```

Publish a Dogfood app, pointing to production by default.

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
