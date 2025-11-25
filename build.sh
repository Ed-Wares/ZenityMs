#!/bin/bash

# Script to rebuild the EXE binary
# You can run it from a msys2 terminal

prj_name=zenity
current_dir=$(dirname "$(realpath "$0")" )

cd "$current_dir"

# g++ -o zenity.exe main.c -lgdi32 -mwindows

echo dependencies can be installed in msys2 with: 
echo pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-toolchain base-devel mingw-w64-ucrt-x86_64-ntldd
echo pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-gnome-common git make automake autoconf libtool yelp-tools
echo pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-gtk3 mingw-w64-ucrt-x86_64-itstool mingw-w64-ucrt-x86_64-gettext msys2-runtime-devel

autoreconf -f -i
./configure --prefix= --disable-nls CPPFLAGS="-Ic:/msys64/usr/include" LDFLAGS="-Lc:/msys64/usr/lib"
make

echo creating dist folder and copying files
mkdir -p ./dist/bin
ldd ./src/zenity.exe | grep mingw64 | awk '{print $3}' | xargs -I {} cp {} ./dist/bin
cp -v ./src/zenity.exe ./dist/bin
cp -v src/zenity.ui ./dist/bin
cp -v src/gdialog ./dist/bin
