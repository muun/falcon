#!/bin/bash

set -e

repo_root=$(git rev-parse --show-toplevel)
build_dir="$repo_root/libwallet/.build"

falcon_root="$repo_root/example"

if ! which gobind > /dev/null; then
    if [ ! -f "$falcon_root/.gopath" ]; then
        echo "error: you need to run pod install"
        exit 1
    fi

    MAIN_GOPATH="$(cat $falcon_root/.gopath)"
    GOPATH="$MAIN_GOPATH:$PWD/libwallet"
    PATH="$PATH:$MAIN_GOPATH/bin"
fi

cd "$repo_root"

libwallet="$repo_root/core/Libwallet.framework"

# if there is an existing build, check if it is up-to-date
if [ -e "$libwallet" ]; then
    last_modified=$(find libwallet/ -xdev -type f -name "*.go" -print | grep -v "_test.go$" | grep -v "/build/" | xargs stat -f "%m%t%Sm %N" "${libwallet}/" | sort -nr | head -n 1)
    if [[ $last_modified == *"$libwallet"* ]]; then
        echo "no rebuild needed"
        exit
    fi
fi

cd libwallet/

# Create the cache folders
mkdir -p "$build_dir/ios"
mkdir -p "$build_dir/pkg"

# Use a shared dependency cache between iOS and Android by setting GOMODCACHE

# Setting CGO_LDFLAGS_ALLOW is a hack to build with golang 1.15.5
# https://github.com/golang/go/issues/42565#issuecomment-727214122

CGO_LDFLAGS_ALLOW="-fembed-bitcode" \
    GOMODCACHE="$build_dir/pkg" \
    go run golang.org/x/mobile/cmd/gomobile bind -target=ios -o "$libwallet" -cache "$build_dir/ios" .

st=$?
echo "rebuilt gomobile with status $? to $libwallet"
exit $st
