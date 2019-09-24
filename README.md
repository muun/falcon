![muun](https://muun.com/images/github-banner-v2.png)

## About

This is the source code repository for muun's iOS wallet. Muun is a non-custodial 2-of-2 multisig wallet with a special focus on security and ease of use.

## Setup

1. Install [golang](https://golang.org/)
2. Make sure you've set the GOPATH env var correctly
3. Install [gomobile](https://godoc.org/golang.org/x/mobile/cmd/gomobile)
4. Install [cocoapods](https://guides.cocoapods.org/using/getting-started.html)
5. Make sure you have Xcode command line tools installed. You can check this in Xcode  > Preferences > Locations > Command Line tools
6. Run `tools/bootstrap-gomobile.sh`. This will install gomobile and bind libwallet to your GOPATH.
7. Run `cd example && pod install`
8. You're done! Open the workspace file and try building the project.

## Structure

The app has three layers:

* **Data:** handles the data backends, such as the database, the operating system, or the network.
* **Domain:** contains the models and business logic (use cases in clean architecture lingo).
* **Presentation:** contains the UI code, not included in this repository.
* **libwallet:** contains the crypto and bitcoin specific code. It's written in golang and bridged using gomobile.

## Auditing

* Most of the key handling and transaction crafting operations happen in the **libwallet** module.
* All the secure storage and data handling happens in the **data** layer.
* All the business logic that decides when to sign what happens in the **domain** layer.

## Responsible Disclosure

Send us an email to report any security related bugs or vulnerabilities at [security@muun.com](mailto:security@muun.com).

You can encrypt your email message using our public PGP key.

Public key fingerprint: `1299 28C1 E79F E011 6DA4 C80F 8DB7 FD0F 61E6 ED76`

