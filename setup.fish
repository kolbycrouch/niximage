#!/usr/bin/env fish

## Create temp directory.
if test -d ./tmp
 true
else 
 mkdir ./tmp
end

## Copy closure of chosen derivation into AppImage root directory.

if test -d ./$APPNAME/nix
 true
else
 mkdir -p $APPNAME
 nix copy --no-check-sigs --to $PWD/$APPNAME $DERIVATIONPATH
end

## Copy static dash shell into AppImage root directory.

if test -e ./$APPNAME/dash
 true
else
 cp (which dash) $APPNAME/dash
end

## Copy static AppRun into AppImage root directory.

if test -e ./$APPNAME/AppRun
 true
else
 cp (which AppRun) $APPNAME/AppRun
end

## Copy static proot binary into AppImage root directory.

if test -e ./$APPNAME/proot
 true
else
 cp (which proot) $APPNAME/proot
end

## Modify and compile startup binary run.c

if test -e ./$APPNAME/run
  true
else
 cp ./run.c tmp/run.c
 sed -i -e "s:APPNAME:$APPNAME:g" ./tmp/run.c
 sed -i -e "s:DERIVATIONPATH:$DERIVATIONPATH:g" ./tmp/run.c
 gcc -static -Os -flto ./tmp/run.c -o $APPNAME/run
end

## Modify and copy startup script.

if test -e ./$APPNAME/run.sh
  true
else
 cp ./run.sh tmp/run.sh
 sed -i -e "s:APPNAME:$APPNAME:g" ./tmp/run.sh
 sed -i -e "s:DERIVATIONPATH:$DERIVATIONPATH:g" ./tmp/run.sh
 cp ./tmp/run.sh $APPNAME/run.sh
end

## Copy template .desktop file.

if test -e ./$APPNAME/$APPNAME.desktop
 true
else
 cp ./template.desktop ./$APPNAME/$APPNAME.desktop
 sed -i -e "s:APPNAME:$APPNAME:g" ./$APPNAME/$APPNAME.desktop
end

## Create fake png icon.

if test -e ./$APPNAME/null.png
 true
else
 touch ./$APPNAME/null.png
end

## Copy appimagetool into build directory.

if test -e ./appimagetool.$APPNAME
 true
else
 cp (which appimagetool) ./appimagetool.$APPNAME
end
