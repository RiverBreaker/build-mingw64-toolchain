WORKDIR="${GITHUB_WORKSPACE:-$(pwd)}"
export PREFIX="$WORKDIR/build/ubuntu-tools/mingw64"
export BUILD_TEMP="$WORKDIR/build/build-temp"
export SRC_DIR="$WORKDIR/build/src"
export TARGET=x86_64-w64-mingw32
export BUILD=x86_64-pc-linux-gnu
export HOST=x86_64-pc-linux-gnu
export PATH=$PATH:$PREFIX/bin

cd $BUILD_TEMP
for d in build-gnu-gmp build-gnu-mpfr build-gnu-mpc build-gnu-isl build-gnu-cloog; do
    [ -d "$d" ] && rm -rf "$d"
done
mkdir -p build-gnu-gmp build-gnu-mpfr build-gnu-mpc build-gnu-isl build-gnu-cloog
echo "mkdir build-gnu-gmp build-gnu-mpfr build-gnu-mpc build-gnu-isl build-gnu-cloog"


src=$(realpath --relative-to="${BUILD_TEMP}/build-gnu-gmp" "${SRC_DIR}")

# Build dependencies
# #
# Build GMP
cd build-gnu-gmp
${src}/gcc/gmp/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --disable-shared \
    --enable-static \
    --enable-cxx
echo "Configure GMP completed."
make -j1 && make install
echo "Build GMP completed."
cd $BUILD_TEMP

# Build MPFR
cd build-gnu-mpfr
${src}/gcc/mpfr/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --disable-shared \
    --enable-static \
    --with-gmp=$PREFIX
echo "Configure MPFR completed."
make -j1 && make install
echo "Build MPFR completed."
cd $BUILD_TEMP

# Build MPC
cd build-gnu-mpc
${src}/gcc/mpc/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --disable-shared \
    --enable-static \
    --with-mpfr=$PREFIX \
    --with-gmp=$PREFIX
echo "Configure MPC completed."
make -j1 && make install
echo "Build MPC completed."
cd $BUILD_TEMP

# Build ISL
cd build-gnu-isl
${src}/gcc/isl/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --disable-shared \
    --enable-static \
    --with-gmp-prefix=$PREFIX
echo "Configure ISL completed."
make -j1 && make install
echo "Build ISL completed."
cd $BUILD_TEMP


PREFIX="$WORKDIR/build/ubuntu-tools/mingw64"

echo "PKG_CONFIG_PATH: $PKG_CONFIG_PATH"
echo "Check pkg-config for isl:"
pkg-config --modversion isl || echo "pkg-config can't find isl"

echo "pkg-config cflags/libs for isl:"
pkg-config --cflags isl || true
pkg-config --libs isl || true

echo "List pkgconfig files under PREFIX:"
ls -la "$PREFIX/lib/pkgconfig" || true

echo "List installed lib files:"
ls -la "$PREFIX/lib" | egrep "libisl|isl" || true

echo "Search for symbol in static/shared library (if exists):"
if [ -f "$PREFIX/lib/libisl.a" ]; then
  nm -g "$PREFIX/lib/libisl.a" | grep isl_set_copy_basic_set || true
fi
if [ -f "$PREFIX/lib/libisl.so" ]; then
  nm -D "$PREFIX/lib/libisl.so" | grep isl_set_copy_basic_set || true
fi

# Build Cloog
cd build-gnu-cloog
${src}/cloog/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --disable-shared \
    --enable-static \
    --with-gmp-prefix=$PREFIX \
    --with-isl-prefix=$PREFIX
echo "Configure Cloog completed."
make -j1 && make install
echo "Build Cloog completed."


for d in build-gnu-gmp build-gnu-mpfr build-gnu-mpc build-gnu-isl build-gnu-cloog; do
    [ -d "$d" ] && rm -rf "$d"
done