export PREFIX="${{ github.workspace }}/build/ubuntu-tools/mingw64"
export BUILD_TEMP="${{ github.workspace }}/build/build-temp"
export SRC_DIR="${{ github.workspace }}/build/src"
export TARGET=x86_64-w64-mingw32
export BUILD=x86_64-pc-linux-gnu
export HOST=x86_64-pc-linux-gnu
export PATH=$PATH:$PREFIX/bin

cd $BUILD_TEMP
if [ -d build-gnu-binutils ]; then
    rm -rf build-gnu-binutils
    echo "remove build-gnu-binutils"
fi
mkdir -p build-gnu-binutils
echo "mkdir build-gnu-binutils"

binutils_src=$(realpath --relative-to="${BUILD_TEMP}/build-gnu-binutils" "${SRC_DIR}/binutils")

cd $BUILD_TEMP/build-gnu-binutils
${binutils_src}/configure \
    --target=$TARGET \
    --build=$BUILD \
    --prefix=$PREFIX \
    --with-sysroot=$PREFIX/$TARGET \
    --enable-static \
    --disable-shared \
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

if [ -d build-gnu-binutils ]; then
    rm -rf build-gnu-binutils
    echo "remove build-gnu-binutils"
fi
