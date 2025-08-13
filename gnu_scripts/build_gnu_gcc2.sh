WORKDIR="${GITHUB_WORKSPACE:-$(pwd)}"
export PREFIX="$WORKDIR/build/ubuntu-tools/mingw64"
export BUILD_TEMP="$WORKDIR/build/build-temp"
export SRC_DIR="$WORKDIR/build/src"
export TARGET=x86_64-w64-mingw32
export BUILD=x86_64-pc-linux-gnu
export HOST=x86_64-pc-linux-gnu
export PATH=$PATH:$PREFIX/bin

cd $BUILD_TEMP
for d in build-gnu-headers build-gnu-gendef build-gnu-genidl build-gnu-widl build-gnu-crt; do
    [ -d "$d" ] && rm -rf "$d" && echo "remove $d"
done
if [ -d build-gnu-gcc2 ]; then
    rm -rf build-gnu-gcc2
    echo "remove build-gnu-gcc2"
fi
mkdir -p build-gnu-gcc2
echo "mkdir build-gnu-gcc2"

gcc_src=$(realpath --relative-to="${BUILD_TEMP}/build-gnu-gcc2" "${SRC_DIR}/gcc")

cd build-gnu-gcc2
${gcc_src}/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$BUILD \
    --target=$TARGET \
    --with-local-prefix=$PREFIX/local \
    --program-prefix=$TARGET- \
    --disable-nls \
    --disable-lto \
    --disable-multilib \
    --disable-libssp \
    --disable-libmudflap \
    --disable-libstdcxx-pch \
    --disable-symvers \
    --disable-shared \
    --enable-static \
    --enable-languages=c,c++ \
    --enable-libstdcxx-debug \
    --enable-version-specific-runtime-libs \
    --enable-decimal-float=yes \
    --enable-threads=win32 \
    --enable-tls \
    --enable-fully-dynamic-string \
    --with-gnu-ld \
    --with-gnu-as \
    --with-libiconv \
    --with-system-zlib \
    --without-newlib \
    --with-sysroot=$PREFIX/$TARGET \
    --with-gmp=$PREFIX \
    --with-mpfr=$PREFIX \
    --with-mpc=$PREFIX \
    --with-isl=$PREFIX
echo "Configure gcc stage 2 done"
make -j1 && make install
echo "Build gcc stage 2 done"

if [ -d build-gnu-gcc2 ]; then
    rm -rf build-gnu-gcc2
    echo "remove build-gnu-gcc2"
fi

cd $BUILD_TEMP
if [ -d build-gnu-libiconv ]; then
    rm -rf build-gnu-libiconv
    echo "remove build-gnu-libiconv"
fi
mkdir -p build-gnu-libiconv
echo "mkdir build-gnu-libiconv"

libiconv_src=$(realpath --relative-to="${BUILD_TEMP}/build-gnu-libiconv" "${SRC_DIR}/libiconv")

cd build-gnu-libiconv
${libiconv_src}/configure \
    --prefix=$PREFIX/$TARGET \
    --build=$BUILD \
    --host=$HOST \
    --enable-extra-encodings \
    --enable-static \
    --disable-shared \
    --disable-nls \
    --with-gnu-ld
echo "Configure libiconv done"
make -j1 && make install
echo "Build libiconv done"

if [ -d build-gnu-libiconv ]; then
    rm -rf build-gnu-libiconv
    echo "remove build-gnu-libiconv"
fi