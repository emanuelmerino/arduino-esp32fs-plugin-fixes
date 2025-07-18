#!/usr/bin/env bash

if [[ -z "$INSTALLDIR" ]]; then
    INSTALLDIR="$HOME/Documents/Arduino"
fi
if [[ -z "$IDEDIR" ]]; then
    IDEDIR="/Applications/Arduino.app/Contents/Java/"
    #IDEDIR="../../../"
fi
echo "INSTALLDIR: $INSTALLDIR"

pde_path=`find $IDEDIR -name pde.jar`
core_path=`find $IDEDIR -name arduino-core.jar`
lib_path=`find $IDEDIR -name commons-codec-1.7.jar`
if [[ -z "$core_path" || -z "$pde_path" ]]; then
    echo "Some java libraries have not been built yet (did you run ant build?)"
    return 1
fi
echo "pde_path: $pde_path"
echo "core_path: $core_path"
echo "lib_path: $lib_path"

set -e

mkdir -p bin
/Library/Java/JavaVirtualMachines/jdk-24.jdk/Contents/Home/bin/javac -target 24 -cp "$pde_path:$core_path:$lib_path" \
      -d bin src/ESP32FS.java

pushd bin
mkdir -p $INSTALLDIR/tools
rm -rf $INSTALLDIR/tools/ESP32FS
mkdir -p $INSTALLDIR/tools/ESP32FS/tool
zip -r $INSTALLDIR/tools/ESP32FS/tool/esp32fs.jar *
popd

dist=$PWD/dist
rev=$(git describe --tags)
mkdir -p $dist
pushd $INSTALLDIR/tools
zip -r $dist/ESP32FS-$rev.zip ESP32FS/
popd
