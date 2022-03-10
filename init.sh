#!/bin/bash

basedir=$(pwd)
workdir=$basedir/work
extractdir=$workdir/extract
decompdir=$workdir/decomp

if [ ! -e "$workdir/launcher.jar" ]; then
    echo "Downloading vanilla launcher..."
    mkdir -p work
    curl -o work/launcher.jar https://launcher.mojang.com/v1/objects/eabbff5ff8e21250e33670924a0c5e38f47c840b/launcher.jar > /dev/null
    if [ "$?" != "0" ]; then
        echo "Failed to download launcher jar"
        exit 1
    fi
fi

if [ ! -e "$extractdir" ]; then
    echo "Extracting classes..."
    mkdir -pv $extractdir
    pushd work/extract
    jar xf ../launcher.jar
    resultvar=$?
    if [ "$resultvar" != "0" ]; then
        echo "Failed to extract jar"
        exit 1
    fi

    echo "Pruning classes..."
    rm -rf org joptsimple javax com/google
    popd
fi

if [ ! -e "$decompdir" ]; then
    echo "Decompiling..."
    mkdir -pv $decompdir
    java -jar tools/fernflower.jar -dgs=1 -hdc=0 -rbr=0 -asc=1 -udv=0 "$extractdir" "$decompdir"
    if [ "$?" != "0" ]; then
        echo "Failed to decompile classes"
        exit 1
    fi
fi
