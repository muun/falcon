#!/bin/bash

cd $(git rev-parse --show-toplevel)

FALCON_ROOT="example"

if [ ! -f "$FALCON_ROOT/.gopath" ]; then
    echo "error: you need to run pod install"
    exit 1
fi

MAIN_GOPATH="$(cat $FALCON_ROOT/.gopath)"
GOPATH="$MAIN_GOPATH:$PWD/libwallet"
PATH="$PATH:$MAIN_GOPATH/bin"
libwallet="core/Libwallet.framework"

last_modified=$(find libwallet/ -xdev -type f -name "*.go" -print | grep -v "_test.go$" | xargs stat -f "%m%t%Sm %N" "${libwallet}/" | sort -nr | head -n 1)
if [[ $last_modified == *"$libwallet"* ]]; then
    echo "no rebuild needed"
else
	GO111MODULE=off gomobile bind -v -target=ios -o "$libwallet" github.com/muun/muun/libwallet
    st=$?
    echo "rebuilt gomobile with status $? to $libwallet"
    exit $st
fi

