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

for d in \
    build-mingw-headers build-mingw-gendef build-mingw-genidl \
    build-mingw-widl build-mingw-crt build-mingw-libmangle \
    build-mingw-genpeimg; do
    [ -d "$d" ] && rm -rf "$d" && echo "remove $d"
done

for d in build-mingw-winpthreads build-mingw-winstorecompat; do
    [ -d "$d" ] && rm -rf "$d" && echo "remove $d"
done

if [ -d build-mingw-gcc2 ]; then
    rm -rf build-mingw-gcc2
    echo "remove build-mingw-gcc2"
fi
mkdir -p build-mingw-gcc2
echo "mkdir build-mingw-gcc2"

gcc_src=$(realpath --relative-to="${BUILD_TEMP}/build-mingw-gcc2" "${SRC_DIR}/gcc")

cd $BUILD_TEMP/build-mingw-gcc2
${gcc_src}/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$HOST \
    --target=$TARGET \
    --with-local-prefix=$PREFIX/local \
    --disable-nls \
    --disable-lto \
    --disable-multilib \
    --disable-win32-registry \
    --disable-libstdcxx-pch \
    --disable-symvers \
    --enable-shared \
    --enable-static \
    --enable-languages=c,c++ \
    --enable-libstdcxx-debug \
    --enable-version-specific-runtime-libs \
    --enable-decimal-float=yes \
    --enable-threads=posix \
    --enable-tls \
    --enable-fully-dynamic-string \
    --with-gnu-ld \
    --with-gnu-as \
    --without-newlib \
    --with-libiconv \
    --with-gmp=$PREFIX \
    --with-mpfr=$PREFIX \
    --with-mpc=$PREFIX \
    --with-isl=$PREFIX
echo "Configure gcc stage 2 done"
make -j1 && make install
echo "Build gcc stage 2 done"

cd $BUILD_TEMP
if [ -d build-mingw-libiconv ]; then
    rm -rf build-mingw-libiconv
    echo "remove build-mingw-libiconv"
fi
mkdir -p build-mingw-libiconv
echo "mkdir build-mingw-libiconv"

libiconv_src=$(realpath --relative-to="${BUILD_TEMP}/build-mingw-libiconv" "${SRC_DIR}/libiconv")

cd $BUILD_TEMP/build-mingw-libiconv
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

cp $PREFIX/lib/gcc/$TARGET/*.dll $PREFIX/bin
cp $PREFIX/lib/gcc/$TARGET/lib/* $PREFIX/lib

echo "Mingw-w64 toolchain build completed successfully!"
echo "Toolchain installed in: $PREFIX"

echo "gcc/g++ version:"
echo "gcc version:"
$PREFIX/bin/x86_64-w64-mingw32-gcc --version
echo "g++ version:"
$PREFIX/bin/x86_64-w64-mingw32-g++ --version