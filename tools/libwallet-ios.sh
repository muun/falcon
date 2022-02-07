#!/bin/bash

set -e

repo_root=$(git rev-parse --show-toplevel)
build_dir="$repo_root/libwallet/.build"

falcon_root="$repo_root/falcon/app"

calc_sha1sum() {
    files=$(find "$1" -xdev -type f -name "*.go" -print \
            | grep -v "_test.go$" | grep -v "/build/" \
            | grep -v ".build/" | sort -z)
    shaeach=$(for file in $files; do sha1sum "$file"; done)
    echo "$shaeach $(sha1sum $(which go)) $(sha1sum "$1/go.mod")" | sha1sum | awk \{'print $1'\}
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
    if ! go version | grep "go1.17.6-muun" > /dev/null ; then
        echo "Misconfigured golang version. Expected go1.17.6-muun."
        go version
        exit 1
    fi
fi

cd "$repo_root"

libwallet="$repo_root/falcon/core/Libwallet.framework"

# if there is an existing build, check if it is up-to-date
if [ -e "$libwallet/libwallet.sha1sum" ]; then
    current_sha1sum=$(calc_sha1sum "libwallet/")
    previous_sha1sum=$(cat "${libwallet}/libwallet.sha1sum")

    if [[ "$current_sha1sum" == "$previous_sha1sum" ]]; then
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
    go run golang.org/x/mobile/cmd/gomobile bind \
    -target=ios -o "$libwallet" -cache "$build_dir/ios" \
    . ./newop 

st=$?

cd "$repo_root"

sha1sum=$(calc_sha1sum "libwallet/")
echo "$sha1sum" > "${libwallet}/libwallet.sha1sum"

echo "rebuilt gomobile with status $? to $libwallet. source files sha1sum: $sha1sum"
exit $st
