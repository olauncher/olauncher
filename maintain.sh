#!/bin/bash

basedir=$(pwd)

# Requires strings, grep, jq, lzma (unless nolzma is specified)
getNewJavaRuntimeManifest() {
  jrework="$basedir/work/jremanifest"
  mkdir -p "$jrework"

  if [ "$1" == "nolzma" ] || ! command -v lzma > /dev/null; then
    forcenolzma="1"
    echo "Not using lzma (nolzma specified or lzma command not found)"
  else
    forcenolzma="0"
  fi

  echo Searching for minecraft-launcher...
  mclauncherloc=$(command -v minecraft-launcher)
  if [ "$?" != "0" ]; then
    echo "Unable to find minecraft-launcher. Please make sure it is installed."
    return 1
  fi

  echo "Found launcher at ${mclauncherloc}."

  echo "Searching for launcher manifest in the binary..."
  launchmanifestloc=$(strings -10 "$mclauncherloc" | grep "https://launchermeta\\.mojang\\.com/v1/products/launcher/.*/linux\\.json")
  if [ "$?" != "0" ] || [ -e $launchmanifestloc ]; then
    echo "Unable to find the manifest in the launcher binary."
    return 1
  fi

  echo "Found manifest location at ${launchmanifestloc}."
  echo "Downloading manifest to find launcher-core manifest..."
  curl -so "$jrework/launcher.json" "${launchmanifestloc}"
  if [ "$?" != "0" ]; then
    echo "Error downloading launcher manifest"
    return 1
  fi

  echo "Parsing manifest to find the launcher-core manifest location..."
  launchercoremanifestloc=$(cat "$jrework/launcher.json" | jq -Mcr '.["launcher-core"][0]["manifest"]["url"]')
  if [ "$?" != "0" ] || [ -e $launchercoremanifestloc ]; then
    echo "Unable to parse manifest."
    exit 1
  fi

  echo "Found core manifest location at ${launchercoremanifestloc}."
  echo "Downloading launcher-core manifest to find liblauncher.so..."
  curl -so "$jrework/launcher-core.json" "${launchercoremanifestloc}" 2> /dev/null
  if [ "$?" != "0" ]; then
    echo "Error downloading launcher-core manifest"
    return 1
  fi

  echo "Parsing manifest to find liblauncher.so location..."
  liblaunchercompressed="1"
  liblauncherloc=$(cat "$jrework/launcher-core.json" | jq -Mcr '.["files"]["liblauncher.so"]["downloads"]["lzma"]["url"]')
  if [ "$?" != "0" ] || [ "$liblauncherloc" == "null" ] || [ "$forcenolzma" == "1" ]; then
    echo "Unable to find lzma location or nolzma specified, resorting to raw location..."
    liblaunchercompressed="0"
    liblauncherloc=$(cat "$jrework/launcher-core.json" | jq -Mcr '.["files"]["liblauncher.so"]["downloads"]["raw"]["url"]')
    if [ "$?" != "0" ] || [ "$liblauncherloc" == "null" ]; then
      echo "Unable to find raw liblauncher location."
      return 1
    fi
  fi

  if [ "$liblaunchercompressed" == "1" ]; then
    echo "Found compressed liblauncher.so location at ${liblauncherloc}"
    echo "Downloading compressed liblauncher.so"
    curl -so "$jrework/liblauncher.so.lzma" "${liblauncherloc}"
    if [ "$?" != "0" ]; then
      echo "Unable to download compressed liblauncher.so"
      return 1
    fi

    echo "Decompressing liblauncher.so.lzma"
    lzma -df "$jrework/liblauncher.so.lzma"

    if [ "$?" != "0" ]; then
      echo "Unable to decompress liblauncher.so.lzma"
      rm -v "$jrework/liblauncher.so.lzma"
      return 1
    fi
  else
    echo "Found liblauncher.so location at ${liblauncherloc}"
    echo "Downloading liblauncher.so"
    curl -so "$jrework/liblauncher.so" "${liblauncherloc}"
    if [ "$?" != "0" ]; then
      echo "Unable to download liblauncher.so"
      return 1
    fi
  fi

  echo "Scanning liblauncher.so for java-runtime manifest..."
  jremanifestloc=$(strings -10 "$jrework/liblauncher.so" | grep "https://launchermeta\\.mojang\\.com/v1/products/java-runtime/.*\\.json")
  if [ "$?" != "0" ] || [ -e $jremanifestloc ]; then
    echo "Unable to find java-runtime manifest location."
    return 1
  fi

  echo "Cleaning up."
  rm -vfr "$jrework"

  echo -e "Found java-runtime manifest location at \e[1m${jremanifestloc}\e[0m ."
}

command=$1
case $command in
getJREManifest)
  getNewJavaRuntimeManifest ${@:2}
  exit $?
  ;;
*)
  echo "Invalid command."
  exit 1
esac
