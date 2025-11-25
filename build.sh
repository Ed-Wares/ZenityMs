#!/bin/bash
prj_name=zenity
current_dir=$(dirname "$(realpath "$0")" )

cd "$current_dir"
# Script to rebuild the EXE binary
# You can run it from a msys2 terminal

# g++ -o zenity.exe main.c -lgdi32 -mwindows

echo dependencies can be installed in msys2 with: 
echo pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-toolchain base-devel mingw-w64-ucrt-x86_64-ntldd
echo pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-gnome-common git make automake autoconf libtool yelp-tools
echo pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-gtk3 mingw-w64-ucrt-x86_64-itstool mingw-w64-ucrt-x86_64-gettext msys2-runtime-devel

autoreconf -f -i
./configure --prefix= --disable-nls
make

mkdir -p "$current_dir"/dist/bin
ldd "$current_dir"/src/"$prj_name".exe | grep mingw64 | awk '{print $3}' | xargs -I {} cp {} "$current_dir"/dist/bin
cp -v "$current_dir"/src/"$prj_name".exe "$current_dir"/dist/bin
cp -v src/gdialog "$current_dir"/dist/bin
