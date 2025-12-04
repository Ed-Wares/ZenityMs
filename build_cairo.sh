#!/bin/bash
# Script to build cairo and pango with software acceleration instead of hardware

current_dir=$(dirname "$(realpath "$0")" )

echo "Building cairo with software acceleration instead of hardware"

# 1. Install build dependencies
echo dependencies can be installed in msys2 with: 
echo pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-meson mingw-w64-ucrt-x86_64-ninja

# 2. Create a build workspace
rm -rf $current_dir/cairo_build
mkdir -p $current_dir/cairo_build
cd $current_dir/cairo_build

# 3. Download cairo-1.18.4, which is what originally msys2 had
#wget https://cairographics.org/releases/cairo-1.18.0.tar.xz
wget https://cairographics.org/releases/cairo-1.18.4.tar.xz
tar -xf cairo-1.18.4.tar.xz
cd cairo-1.18.4


# Verify your environment is clean
rm -rf _build

# Run Meson configuration with dwrite=disabled
#meson setup _build --prefix=$current_dir/cairo_build/dist --buildtype=release -D dwrite=disabled -D tests=disabled
meson setup _build --prefix=$current_dir/cairo_build/dist --buildtype=release -D dwrite=disabled -D freetype=enabled -D fontconfig=enabled -D tests=disabled -D lzo=disabled

# Compile
ninja -C _build install
#ninja -C _build src/libcairo-2.dll

#echo Copying cairo dll to dist folder
#mkdir -p $current_dir/cairo_build/dist/bin
#cp -v _build/src/libcairo-2.dll $current_dir/cairo_build/dist/bin

# Install to our local dist folder
#ninja -C _build install

echo "Cairo build complete. The binaries are in $current_dir/cairo_build/dist/bin"
ls -l $current_dir/cairo_build/dist/bin


# Build pango with software acceleration instead of hardware
rm -rf $current_dir/pango_build
mkdir -p $current_dir/pango_build
cd $current_dir/pango_build

# Download pango 1.56.4.0 (matches most MSYS2 installs)
wget https://download.gnome.org/sources/pango/1.56/pango-1.56.4.tar.xz
tar -xf pango-1.56.4.tar.xz
cd pango-1.56.4

# Verify your environment is clean
rm -rf _build

# tell it to use the cairo we just built
export PKG_CONFIG_PATH="$current_dir/cairo_build/dist/lib/pkgconfig:$PKG_CONFIG_PATH"
export PATH="$current_dir/cairo_build/dist/bin:$PATH"
echo PKG_CONFIG_PATH: $PKG_CONFIG_PATH
echo PATH: $PATH

#PKG_CONFIG_PATH=$current_dir/cairo_build/dist/lib/pkgconfig meson setup _build --prefix=$current_dir/pango_build/dist --buildtype=release

MESON_FILE="$current_dir/pango_build/pango-1.56.4/meson.build"

# Create inline patch
cat > .disable_dwrite.patch << 'EOF'
--- a/meson.build
+++ b/meson.build
@@ -75,9 +75,10 @@
 endif
 
 # Check for dwrite_3.h (from more recent Windows SDK or mingw-w64)
-if host_system == 'windows' and not cpp.has_header('dwrite_3.h')
-  error('Windows backend enabled but dwrite_3.h not found.')
-endif
+# Disabled DirectWrite support
+# if host_system == 'windows' and not cpp.has_header('dwrite_3.h')
+#   error('Windows backend enabled but dwrite_3.h not found.')
+# endif
 
 # Enable cairo-ft with FreeType and FontConfig support if
 # building as a subproject and FontConfig support is required
@@ -102,17 +103,9 @@
     )
   endif
 
-  # Use hb-directwrite if we are also using cairo-dwrite-font,
-  # or if we are (unlikely) not enabling Cairo support
-  if not cairo_dep.found() or cairo_dwrite_dep.found()
-    if harfbuzz_dep.type_name() == 'internal' or \
-       cpp.has_function('hb_directwrite_face_create', dependencies: harfbuzz_dep)
-      pango_conf.set('USE_HB_DWRITE', 1)
-    endif
-  else
-    if harfbuzz_dep.type_name() == 'internal' or \
-       cc.has_function('hb_gdi_face_create', dependencies: harfbuzz_dep)
-      pango_conf.set('USE_HB_GDI', 1)
-    endif
-  endif
+  # Force GDI usage instead of DirectWrite
+  if harfbuzz_dep.type_name() == 'internal' or \
+     cc.has_function('hb_gdi_face_create', dependencies: harfbuzz_dep)
+    pango_conf.set('USE_HB_GDI', 1)
+  endif
 endif
@@ -185,9 +178,10 @@
 endif
 
-if cairo_dwrite_dep.found()
-  pango_conf.set('HAVE_CAIRO_WIN32_DIRECTWRITE', 1)
-endif
+# Disabled DirectWrite support
+# if cairo_dwrite_dep.found()
+#   pango_conf.set('HAVE_CAIRO_WIN32_DIRECTWRITE', 1)
+# endif
 
 # introspection
 gir = find_program('g-ir-scanner', required : get_option('introspection'))
EOF

# Apply patch
patch -p1 < .disable_dwrite.patch

# Clean up
rm .disable_dwrite.patch

echo "DirectWrite disabled in Pango meson.build"

meson setup _build --prefix=$current_dir/pango_build/dist --buildtype=release
ninja -C _build install

echo "Pango build complete. The binaries are in $current_dir/pango_build/dist/bin"
