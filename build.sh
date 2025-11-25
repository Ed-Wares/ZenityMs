#!/bin/bash

# Script to rebuild the EXE binary
# You can run it from a msys2 terminal

prj_name=zenity
current_dir=$(dirname "$(realpath "$0")" )

cd "$current_dir"

# g++ -o zenity.exe main.c -lgdi32 -mwindows

echo dependencies can be installed in msys2 with: 
echo pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-toolchain base-devel mingw-w64-ucrt-x86_64-ntldd
echo pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-gnome-common git make automake autoconf libtool yelp-tools zip
echo pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-gtk3 mingw-w64-ucrt-x86_64-itstool mingw-w64-ucrt-x86_64-gettext msys2-runtime-devel
# pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-adwaita-icon-theme
autoreconf -f -i
./configure --prefix= --disable-nls CPPFLAGS="-Ic:/msys64/usr/include" LDFLAGS="-Lc:/msys64/usr/lib"
make

echo "Cleaning previous build..."
rm -rf ./dist/zenityMs

echo "Creating dist folders"
mkdir -p ./dist/zenityMs/bin
mkdir -p ./dist/zenityMs/lib
mkdir -p ./dist/zenityMs/ui
mkdir -p ./dist/zenityMs/share
echo "Copying Linked DLLs..."
ldd ./src/zenity.exe | grep "ucrt64/bin/" | awk '{print $3}' | sort | uniq | xargs -I {} cp -v {} "./dist/zenityMs/bin"

echo "Copying binaries and various files..."
cp -v ./src/zenity.exe ./dist/zenityMs/bin/
cp -v src/zenity.ui ./dist/zenityMs/ui
cp -v src/gdialog ./dist/zenityMs/bin/
cp -v zenity.bat ./dist/zenityMs
cp -v zenityTest.bat ./dist/zenityMs
cp -v LICENSE ./dist/zenityMs

echo "Copying icons..."
mkdir -p "./dist/zenityMs/share/icons"
cp -v -r "/ucrt64/share/icons/hicolor" "./dist/zenityMs/share/icons/"
cp -v -r "/ucrt64/share/icons/Adwaita" "./dist/zenityMs/share/icons/"

echo "Copying GDK Pixbuf Loaders..."
mkdir -p "./dist/zenityMs/lib/gdk-pixbuf-2.0/2.10.0/loaders"
# Copy the loader DLLs
cp -v "/ucrt64/lib/gdk-pixbuf-2.0/2.10.0/loaders/"*.dll "./dist/zenityMs/lib/gdk-pixbuf-2.0/2.10.0/loaders/"
# Copy (or generate) the cache file so GTK knows where they are
cp -v "/ucrt64/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache" "./dist/zenityMs/lib/gdk-pixbuf-2.0/2.10.0/"
# Find dependencies of the SVG loader
ldd "/ucrt64/lib/gdk-pixbuf-2.0/2.10.0/loaders/pixbufloader_svg.dll" | grep "/bin/" | awk '{print $3}' | sort | uniq | xargs -I {} cp -n -v {} "./dist/zenityMs/bin/"

# THE MISSING HELPER (Process Spawning)
echo "Copying Process Helper..."
# This is required for Zenity to spawn processes without crashing
cp -v "/ucrt64/bin/gspawn-"*"-helper.exe" "./dist/zenityMs/bin/"
cp -v "/ucrt64/bin/gspawn-"*"-helper-console.exe" "./dist/zenityMs/bin/"

# SCHEMAS (Required to prevent crashes on dialog open)
echo "Copying GLib Schemas..."
mkdir -p "./dist/zenityMs/share/glib-2.0/schemas"
cp -v "/ucrt64/share/glib-2.0/schemas/gschemas.compiled" "./dist/zenityMs/share/glib-2.0/schemas/"

echo "Zipping up the build..."
pushd "./dist/" && zip -r zenity.zip zenityMs && popd
