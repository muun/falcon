#!/usr/bin/env bash

# Build a custom golang to avoid a [random crasher](https://github.com/golang/go/issues/46893).

set -e

GO_VERSION=1.22.1

repo_root=$(git rev-parse --show-toplevel)

patched_go_folder="$repo_root/falcon/go/bin"

PATH="$patched_go_folder:$PATH"

if [[ -x "$patched_go_folder/go" ]]; then
    if ! go version | grep "go${GO_VERSION}" > /dev/null ; then
        echo "Misconfigured golang version. Expected go${GO_VERSION}."
        go version
        echo "Remove the directory $patched_go_folder and run ./tools/patch-go.sh to regenerate it"
        exit 1
    fi
else
    cd $repo_root/falcon
    echo "Building go${GO_VERSION}-muun"
    curl -L "https://go.dev/dl/go${GO_VERSION}.src.tar.gz" -o go.src.tar.gz
    tar -Uxf go.src.tar.gz
    git apply 0001-align-to-ptrsize.patch --directory=falcon/go --ignore-whitespace
    cd go/src
    ./make.bash -a
    ../bin/go version
    cd $repo_root
fi

