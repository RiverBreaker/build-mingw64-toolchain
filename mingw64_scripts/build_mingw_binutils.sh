WORKDIR="${GITHUB_WORKSPACE:-$(pwd)}"
export PREFIX="$WORKDIR/build/mingw64"
export BUILD_TEMP="$WORKDIR/build/build-temp"
export SRC_DIR="$WORKDIR/build/src"
export OUTPUT_DIR="$WORKDIR/build/ubuntu-tools/mingw64"
export TARGET=x86_64-w64-mingw32
export BUILD=x86_64-pc-linux-gnu
export HOST=x86_64-w64-mingw32
export PATH=$PATH:$OUTPUT_DIR/bin

cd $BUILD_TEMP
for d in build-mingw-binutils build-mingw-m4 build-mingw-libtool; do
    [ -d "$d" ] && rm -rf "$d"
done
mkdir -p build-mingw-binutils build-mingw-m4 build-mingw-libtool
echo "mkdir build-mingw-binutils build-mingw-m4 build-mingw-libtools"

binutils_src=$(realpath --relative-to="${BUILD_TEMP}/build-mingw-binutils" "${SRC_DIR}/binutils")
m4_src=$(realpath --relative-to="${BUILD_TEMP}/build-mingw-m4" "${SRC_DIR}/m4")
libtool_src=$(realpath --relative-to="${BUILD_TEMP}/build-mingw-libtool" "${SRC_DIR}/libtool")

cd $BUILD_TEMP/build-mingw-binutils
${binutils_src}/configure \
    --target=$TARGET \
    --build=$BUILD \
    --prefix=$PREFIX \
    --host=$HOST \
    --target=$TARGET \
    --enable-shared \
    --disable-nls \
    --enable-ld \
    --disable-lto \
    --with-mpc=$PREFIX \
    --with-gmp=$PREFIX \
    --with-mpfr=$PREFIX \
    --with-cloog=$PREFIX \
    --with-isl=$PREFIX
echo "Configure Binutils completed."
make -j1 && make install
echo "Build Binutils completed."

cd $BUILD_TEMP/build-mingw-m4
${m4_src}/configure \
    --build=$BUILD \
    --prefix=$PREFIX \
    --host=$HOST \
    --enable-threads=windows \
    --disable-c++
echo "Configure M4 completed."
make -j1 && make install
echo "Build M4 completed."

cd $BUILD_TEMP/build-mingw-libtool
${libtool_src}/configure \
    --build=$BUILD \
    --prefix=$PREFIX \
    --host=$HOST \
    --with-gnu-ld \
    --enable-ltdl-install \
    --enable-shared \
    --disable-static
echo "Configure Libtool completed."
make -j1 && make install
echo "Build Libtool completed."
