#!/bin/sh
# Setup for Linux and Mac devices!
# Make you've installed Haxe prior to running this file!
# https://haxe.org/download/
cd ..
echo Installing dependencies
haxe -cp ./actions/libs-installer -D analyzer-optimize -main Libraries --interp
echo Finished!