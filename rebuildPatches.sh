#!/bin/bash

basedir=$(pwd)

rebuildPatches() {
    from=$1
    to=$2

    mkdir -p ${from}-patches
    pushd $to
    git format-patch -o $basedir/${from}-patches origin/HEAD
    popd
}

rebuildPatches launcher olauncher
