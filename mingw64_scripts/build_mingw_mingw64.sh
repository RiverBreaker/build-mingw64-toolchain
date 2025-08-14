WORKDIR="${GITHUB_WORKSPACE:-$(pwd)}"
export PREFIX="$WORKDIR/build/mingw64"
export BUILD_TEMP="$WORKDIR/build/build-temp"
export SRC_DIR="$WORKDIR/build/src"
export OUTPUT_DIR="$WORKDIR/build/ubuntu-tools/mingw64"
export TARGET=x86_64-w64-mingw32
export BUILD=x86_64-pc-linux-gnu
export HOST=x86_64-w64-mingw32
export PATH=$PATH:$OUTPUT_DIR/bin

# Set cross-compiler environment variables
export CC=$OUTPUT_DIR/bin/x86_64-w64-mingw32-gcc
export CXX=$OUTPUT_DIR/bin/x86_64-w64-mingw32-g++
export AR=$OUTPUT_DIR/bin/x86_64-w64-mingw32-ar
export RANLIB=$OUTPUT_DIR/bin/x86_64-w64-mingw32-ranlib
export STRIP=$OUTPUT_DIR/bin/x86_64-w64-mingw32-strip

cd $BUILD_TEMP
for d in build-mingw-binutils build-mingw-m4 build-mingw-libtool; do
    [ -d "$d" ] && rm -rf "$d" && echo "remove $d"
done
for d in \
    build-mingw-headers build-mingw-gendef build-mingw-genidl \
    build-mingw-widl build-mingw-crt build-mingw-libmangle \
    build-mingw-genpeimg; do
    [ -d "$d" ] && rm -rf "$d" && echo "remove $d"
done
mkdir -p build-mingw-headers build-mingw-gendef build-mingw-genidl \
    build-mingw-widl build-mingw-crt build-mingw-libmangle \
    build-mingw-genpeimg
echo "mkdir build-mingw-headers build-mingw-gendef build-mingw-genidl \
    build-mingw-widl build-mingw-crt build-mingw-libmangle build-mingw-genpeimg"

mingw64_src=$(realpath --relative-to="${BUILD_TEMP}/build-mingw-headers" "${SRC_DIR}/mingw-w64")

# Build libmangle
cd $BUILD_TEMP/build-mingw-libmangle
echo "Configure win mingw libmangle starting..."
${mingw64_src}/mingw-w64-libraries/libmangle/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$HOST
echo "Configure libmangle completed."
make -j1 && make install
echo "Build libmangle completed."

# Build gendef
cd $BUILD_TEMP/build-mingw-gendef
echo "Configure win mingw gendef starting..."
${mingw64_src}/mingw-w64-tools/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$HOST \
    --with-libmangle=$PREFIX
echo "Configure gendef completed."
make -j1 && make install
echo "Build gendef completed."

# Build genidl
cd $BUILD_TEMP/build-mingw-genidl
echo "Configure win mingw genidl starting..."
${mingw64_src}/mingw-w64-tools/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$HOST
echo "Configure genidl completed."
make -j1 && make install
echo "Build genidl completed."

# Build genpeimg
cd $BUILD_TEMP/build-mingw-genpeimg
echo "Configure win mingw genpeimg starting..."
${mingw64_src}/mingw-w64-tools/genpeimg/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$HOST
echo "Configure genpeimg completed."
make -j1 && make install
echo "Build genpeimg completed."

# Build widl
cd $BUILD_TEMP/build-mingw-widl
echo "Configure win mingw widl starting..."
ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes ${mingw64_src}/mingw-w64-tools/configure \
        --prefix=$PREFIX \
        --build=$BUILD \
        --host=$HOST \
        --target=$TARGET \
        --program-prefix=""
echo "Configure widl completed."
make -j1 && make install
echo "Build widl completed."

# Build headers
cd $BUILD_TEMP/build-mingw-headers
echo "Configure win mingw headers starting..."
${mingw64_src}/mingw-w64-headers/configure \
    --prefix=$PREFIX/$TARGET \
    --build=$BUILD \
    --target=$TARGET \
    --host=$HOST \
    --enable-idl \
    --enable-secure-api 
echo "Configure headers completed."
make -j1 && make install
echo "Build headers completed."

# Build crt
cd $BUILD_TEMP/build-mingw-crt
echo "Configure win mingw crt starting..."
AR='$TARGET-ar' \
AS='$TARGET-as' \
CC='$TARGET-gcc' \
CXX='$TARGET-g++' \
DLLTOOL='$TARGET-dlltool' \
RANLIB='$TARGET-ranlib' \
    ${mingw64_src}/mingw-w64-crt/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$HOST \
    --disable-w32api \
    --disable-lib32 \
    --enable-lib64 \
    --enable-private-exports
echo "Configure crt completed."
make -j1 && make install
echo "Build crt completed."