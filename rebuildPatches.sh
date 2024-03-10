#!/bin/bash

basedir=$(pwd)

cleanupPatches() {
  pushd "$1"
  for patch in *.patch; do
    gitver=$(tail -n 2 "$patch" | grep -ve "^$" | tail -n 1)
    diffs=$(git diff --staged "$patch" | grep -E "^(\+|\-)" | grep -Ev "(From [a-z0-9]{32,}|\-\-\- a|\+\+\+ b|.index)")

    testver=$(echo "$diffs" | tail -n 2 | grep -ve "^$" | tail -n 1 | grep "$gitver")
    if [ "x$testver" != "x" ]; then
        diffs=$(echo "$diffs" | sed 'N;$!P;$!D;$d')
    fi

    if [ "x$diffs" == "x" ] ; then
        git reset HEAD "$patch" >/dev/null
        git checkout -- "$patch" >/dev/null
    fi
  done
  popd
}

rebuildPatches() {
    from=$1
    to=$2

    mkdir -p "${from}-patches"
    pushd "$to"
    git format-patch --no-stat -N -o "$basedir/${from}-patches" origin/HEAD
    popd

    git add "${from}-patches"/*.patch
    cleanupPatches "${from}-patches"
}

rebuildPatches launcher olauncher
