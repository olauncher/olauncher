#!/bin/bash

basedir=$(pwd)
autooldir=$basedir/AutoOL
workdir=$basedir/work

OLAUNCHER_VERSION=1.7.3_03
AUTOOL_VERSION=0.1.0

finalname="olauncher-$OLAUNCHER_VERSION-redist.jar"

if [ ! -e "$autooldir" ]; then
  echo "The AutoOL directory could not be found. Please run 'git submodule update --init'"
  exit 1
fi

if [ ! -e "$workdir/redist" ]; then
  mkdir -pv "$workdir/redist"
fi

cd "$workdir/redist"

if [ ! -e "jbsdiff" ]; then
  echo jbsdiff not found! Downloading...

  if ! git clone https://github.com/malensek/jbsdiff.git; then
    echo "Error cloning jbsdiff repository"
    exit 1
  fi

  pushd "jbsdiff"
  git checkout 51b6981d97b4cf386069481707394f37c537b1d5
  mvn clean package -Djdk.version=8
  mvnresult="$?"
  popd

  if [ "$mvnresult" != "0" ]; then
    echo "Error building jbsdiff"
    exit 1
  fi
fi

if [ ! -e "$autooldir/target" ]; then
  echo "AutoOL target directory not found, compiling..."
  pushd "$autooldir"
  mvn clean package
  mvnresult="$?"
  popd

  if [ "$mvnresult" != "0" ]; then
    echo "Error building AutoOL"
    exit 1
  fi
fi

echo "Generating patch..."
if ! java -jar "jbsdiff/target/jbsdiff-1.0.jar" diff "../launcher.jar" "$basedir/olauncher/target/olauncher-${OLAUNCHER_VERSION}.jar" "launcher.patch" || [ ! -e "launcher.patch" ]; then
  echo "Error creating patch"
  exit 1
fi

echo "Generating properties..."
(
cat - << EOP
origurl=https://launcher.mojang.com/v1/objects/eabbff5ff8e21250e33670924a0c5e38f47c840b/launcher.jar
orighash=$(sha1sum "../launcher.jar" | cut -d ' ' -f 1)
origname=launcher.jar
origsz=$(du -b "../launcher.jar" | cut -f 1)
patchres=/launcher.patch
patchsz=$(du -b "launcher.patch" | cut -f 1)
finalhash=$(sha1sum "$basedir/olauncher/target/olauncher-${OLAUNCHER_VERSION}.jar" | cut -d ' ' -f 1)
finalname=patched.jar
finalsz=$(du -b "$basedir/olauncher/target/olauncher-${OLAUNCHER_VERSION}.jar" | cut -f 1)
interactive=true
#mainClass=
EOP
) > "patch.properties"

echo "Inserting patch and properties into jar..."
cp "$autooldir/target/AutoOL-${AUTOOL_VERSION}.jar" "$finalname"
jar -uf "$finalname" "launcher.patch" "patch.properties"
jarres="$?"

if [ "$jarres" != "0" ]; then
  echo "jar returned nonzero exit status $jarres"
  exit 1
fi

mv "$finalname" "$basedir/$finalname"
echo "Redistributable created with name $finalname"
