WORKDIR="${GITHUB_WORKSPACE:-$(pwd)}"
export PREFIX="$WORKDIR/build/ubuntu-tools/mingw64"
export BUILD_TEMP="$WORKDIR/build/build-temp"
export SRC_DIR="$WORKDIR/build/src"
export TARGET=x86_64-w64-mingw32
export BUILD=x86_64-pc-linux-gnu
export HOST=x86_64-pc-linux-gnu
export PATH=$PATH:$PREFIX/bin

cd $BUILD_TEMP
if [ -d build-gnu-binutils ]; then
    rm -rf build-gnu-binutils
    echo "remove build-gnu-binutils"
fi
if [ -d build-gnu-gcc1 ]; then
    rm -rf build-gnu-gcc1
    echo "remove build-gnu-gcc1"
fi
mkdir -p build-gnu-gcc1
echo "mkdir build-gnu-gcc1"

gcc_src=$(realpath --relative-to="${BUILD_TEMP}/build-gnu-gcc1" "${SRC_DIR}/gcc")

cd build-gnu-gcc1
${gcc_src}/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$BUILD \
    --target=$TARGET \
    --program-prefix=$TARGET- \
    --disable-nls \
    --disable-lto \
    --disable-multilib \
    --disable-libssp \
    --disable-libmudflap \
    --disable-libgomp \
    --disable-libgcc \
    --disable-libstdc++-v3 \
    --disable-libatomic \
    --disable-libvtv \
    --disable-libquadmath \
    --enable-sjlj-exceptions \
    --enable-languages=c,c++ \
    --enable-version-specific-runtime-libs \
    --enable-decimal-float=yes \
    --enable-threads=win32 \
    --enable-tls \
    --enable-fully-dynamic-string \
    --with-gnu-ld \
    --with-gnu-as \
    --with-libiconv \
    --with-system-zlib \
    --without-dwarf2 \
    --with-sysroot=$PREFIX/$TARGET \
    --with-local-prefix=$PREFIX/local \
    --with-gmp=$PREFIX \
    --with-mpfr=$PREFIX \
    --with-mpc=$PREFIX \
    --with-isl=$PREFIX
echo "Configure gcc stage 1 done"
make -j1 && make install
echo "Build gcc stage 1 done"