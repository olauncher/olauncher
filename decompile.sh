#!/bin/bash

basedir=$(pwd)
workdir=$basedir/work
extractdir=$workdir/extract
decompdir=$workdir/decomp

if [ ! -e "$workdir/launcher.jar" ]; then
    echo "Downloading vanilla launcher..."
    mkdir -p work
    if ! curl -o work/launcher.jar https://launcher.mojang.com/v1/objects/eabbff5ff8e21250e33670924a0c5e38f47c840b/launcher.jar > /dev/null; then
        echo "Failed to download launcher jar"
        exit 1
    fi
fi

if [ ! -e "$extractdir" ]; then
    echo "Extracting classes..."
    mkdir -pv "$extractdir"
    pushd work/extract
    if ! jar xf ../launcher.jar; then
        echo "Failed to extract jar"
        exit 1
    fi

    echo "Pruning classes..."
    rm -rf org joptsimple javax com/google
    popd
fi

if [ ! -e "$decompdir" ]; then
    echo "Decompiling..."
    mkdir -pv "$decompdir"
    if ! java -jar tools/fernflower.jar -dgs=1 -hdc=0 -asc=1 -udv=0 -ind="    " "$extractdir" "$decompdir"; then
        echo "Failed to decompile classes"
        exit 1
    fi
fi
