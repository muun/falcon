#!/bin/bash

set -e

repo_root=$(git rev-parse --show-toplevel)
build_dir="$repo_root/libwallet/.build"

falcon_root="$repo_root/falcon/app"

this_file_sha=$(shasum "$0")

calc_shasum() {
    files=$(find "$1" -xdev -type f -name "*.go" -print \
            | grep -v "_test.go$" | grep -v "/build/" \
            | grep -v ".build/" | sort -z)
    shaeach=$(for file in $files; do shasum "$file"; done)
    echo "$shaeach "$this_file_sha" $(shasum $(which go)) $(shasum "$1/go.mod")" | shasum | awk \{'print $1'\}
}

if ! which gobind > /dev/null; then
    if [ ! -f "$falcon_root/.gopath" ]; then
        echo "error: you need to run pod install"
        exit 1
    fi

    MAIN_GOPATH="$(cat $falcon_root/.gopath)"
    GOPATH="$MAIN_GOPATH:$PWD/libwallet"
    PATH="$PATH:$MAIN_GOPATH/bin"
fi

patched_go_folder="$repo_root/falcon/go/bin"
if [[ -x "$patched_go_folder/go" ]] || [[ "$CONFIGURATION" = "Release" ]]; then
    PATH="$patched_go_folder:$PATH"
    if ! go version | grep "go1.18.10-muun" > /dev/null ; then
        echo "Misconfigured golang version. Expected go1.18.1-muun."
        go version
        exit 1
    fi
fi

cd "$repo_root"

libwallet="$repo_root/falcon/core/Libwallet.xcframework"

# if there is an existing build, check if it is up-to-date
if [ -e "$libwallet/libwallet.shasum" ]; then
    current_shasum=$(calc_shasum "libwallet/")
    previous_shasum=$(cat "${libwallet}/libwallet.shasum")

    if [[ "$current_shasum" == "$previous_shasum" ]]; then
        echo "no rebuild needed"
        exit
    fi
fi

cd libwallet/

# Create the cache folders
mkdir -p "$build_dir/ios"
mkdir -p "$build_dir/pkg"

# Gomobile crashes if these files exist already
rm -r "$build_dir"/ios/ios/iphoneos/*.framework || true
rm -r "$build_dir"/ios/iossimulator/iphonesimulator/*.framework || true

# Use a shared dependency cache between iOS and Android by setting GOMODCACHE

# Setting CGO_LDFLAGS_ALLOW is a hack to build with golang 1.15.5
# https://github.com/golang/go/issues/42565#issuecomment-727214122

CGO_LDFLAGS_ALLOW="-fembed-bitcode" \
    GOMODCACHE="$build_dir/pkg" \
    go run golang.org/x/mobile/cmd/gomobile bind \
    -target=ios,iossimulator -o "$libwallet" -cache "$build_dir/ios" \
    -iosversion="11.4" \
    . ./newop 

st=$?

cd "$repo_root"

shasum=$(calc_shasum "libwallet/")
echo "$shasum" > "${libwallet}/libwallet.shasum"

echo "rebuilt gomobile with status $? to $libwallet. source files shasum: $shasum"
exit $st
