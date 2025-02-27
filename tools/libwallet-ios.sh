#!/bin/bash

set -e

repo_root=$(git rev-parse --show-toplevel)
build_dir="$repo_root/libwallet/.build"

falcon_root="$repo_root/falcon/app"

this_file_sha=$(shasum "$0")

# Build patched version of go to prevent alignment errors
if [[ -x "$repo_root/tools/patch-go.sh" ]]; then
    . "$repo_root/tools/patch-go.sh"
fi

# gomobile bind generates the src-ios* directories several times, leading to fail with:
# /tmp/go-build3034672677/b001/exe/gomobile: mkdir $GOCACHE/src-ios-arm64: file exists
# exit status 1
# There is no significant change in build times without these folders.
no_cache_found="No src-arm64-* directories found in GOCACHE."

rm -rf "$build_dir"/ios/ios/src-arm64* 2>/dev/null || echo $no_cache_found
rm -rf "$build_dir"/ios/iossimulator/src-amd64* 2>/dev/null || echo $no_cache_found
rm -rf "$build_dir"/ios/iossimulator/src-arm64* 2>/dev/null || echo $no_cache_found


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
    PATH="$MAIN_GOPATH/bin:$PATH"
fi

patched_go_folder="$repo_root/falcon/go/bin"
if [[ -x "$patched_go_folder/go" ]] || [[ "$CONFIGURATION" = "Release" ]]; then
    PATH="$patched_go_folder:$PATH"
    # Change GOROOT to match the go tool path to avoid tooldir pollution.
    GOROOT="$repo_root/falcon/go/"
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

GOCACHE="$build_dir/ios"

# Gomobile crashes if these files exist already
rm -r "$build_dir"/ios/ios/iphoneos/*.framework 2>/dev/null || true
rm -r "$build_dir"/ios/iossimulator/iphonesimulator/*.framework 2>/dev/null|| true
rm -r "$libwallet" 2>/dev/null|| true
rm -r "$build_dir/ios" 2>/dev/null || true

echo "Using go binary $(which go) $(go version)"

# Install and setup gomobile on demand (no-op if already installed and up-to-date)
. "$repo_root/tools/bootstrap-gomobile.sh"

CGO_LDFLAGS="-lresolv" \
    go run golang.org/x/mobile/cmd/gomobile bind \
    -target=ios,iossimulator -o "$libwallet" \
    -iosversion="11.4" \
    . ./newop

st=$?

cd "$repo_root"

shasum=$(calc_shasum "libwallet/")
echo "$shasum" > "${libwallet}/libwallet.shasum"

echo "rebuilt gomobile with status $? to $libwallet. source files shasum: $shasum"
exit $st
