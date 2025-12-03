#!/bin/bash

# Script to rebuild the EXE binary and creates a distributable zip file
# You can run it from a msys2 terminal

prj_name=zenity
current_dir=$(dirname "$(realpath "$0")" )

echo "Building $prj_name from $current_dir ..."
cd "$current_dir"

msys_include=$(cygpath -m /usr/include)
msys_lib=$(cygpath -m /usr/lib)
echo "Found include path: $msys_include, lib path: $msys_lib"

echo dependencies can be installed in msys2 with: 
echo pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-toolchain base-devel mingw-w64-ucrt-x86_64-ntldd
echo pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-gnome-common git make automake autoconf libtool yelp-tools zip
echo pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-gtk3 mingw-w64-ucrt-x86_64-itstool mingw-w64-ucrt-x86_64-gettext msys2-runtime-devel
# pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-adwaita-icon-theme

make clean

#fix issues with windows new line characters breaking the configure.ac list
#sed -i 's/\r$//' configure.ac

autoreconf -fiv
./configure --prefix= --disable-nls CPPFLAGS="-I$msys_include" LDFLAGS="-L$msys_lib"
#./configure --prefix= --disable-nls CPPFLAGS="-I${MINGW_PREFIX}/include" LDFLAGS="-L${MINGW_PREFIX}/lib"
make || exit 1 # If 'make' fails, exit with status 1.

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
cp -v zenityDebug.bat ./dist/zenityMs
cp -v COPYING ./dist/zenityMs

echo "Copying gdb and dependencies"
mkdir -p "./dist/zenityMs/gdb"
cp -v /ucrt64/bin/gdb.exe ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/libexpat-1.dll ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/libtermcap-0.dll ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/libmpfr-6.dll ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/libwinpthread-1.dll ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/libxxhash.dll ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/libreadline8.dll ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/zlib1.dll ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/libpython3.12.dll ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/libgcc_s_seh-1.dll ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/libiconv-2.dll ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/libstdc++-6.dll ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/libgmp-10.dll ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/liblzma-5.dll ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/libintl-8.dll ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/libncursesw6.dll ./dist/zenityMs/gdb/
cp -v /ucrt64/bin/libzstd.dll ./dist/zenityMs/gdb/
cp -v dependencies.sh ./dist/zenityMs/gdb/
cp -v dependencies.bat ./dist/zenityMs/gdb/

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
ls -lh ./dist/zenity.zip

echo "Verifying the build..."
objdump -h ./dist/zenityMs/bin/zenity.exe | grep debug
ls -lh ./dist/zenityMs/bin/zenity.exe

echo "Build complete!"
