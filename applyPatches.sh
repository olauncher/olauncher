#!/bin/bash

basedir=$(pwd)

applyPatches() {
    from=$1
    to=$2

    git clone $1 $2
    pushd $2
    git remote add upstream ../$from
    git fetch upstream
    git reset --hard upstream/master
    git am --abort > /dev/null 2>&1
    git am --3way --ignore-whitespace "$basedir/${from}-patches/"*.patch
    patchresult=$?
    popd

    if [ "$patchresult" == "0" ]; then
        echo "Patches applied cleanly to $to!"
    else
        echo "Patches did not apply cleanly to $to. Please fix."
    fi
}

applyPatches launcher olauncher
