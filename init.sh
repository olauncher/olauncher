#!/bin/bash

basedir=$(pwd)
workdir=$basedir/work
decompdir=$workdir/decomp
vanilladir=$basedir/launcher
olauncherdir=$basedir/olauncher

if [ ! -e "$vanilladir" ]; then
    echo "Copying vanilla sources..."
    mkdir -p "$vanilladir"
    pushd "$vanilladir"
    git init
    cp -rv ${decompdir}/* .
    git add --all
    git commit --no-gpg-sign -m "Initial commit"
    popd
fi
