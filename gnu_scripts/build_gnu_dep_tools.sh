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
cd $BUILD_TEMP/build-gnu-gmp
echo "Start to Configure GMP"
${src}/gcc/gmp/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --disable-shared \
    --enable-static \
    --enable-cxx
echo "Configure GMP completed."
make -j1 && make install
echo "Build GMP completed."

# Build MPFR
cd $BUILD_TEMP/build-gnu-mpfr
echo "Start to Configure MPFR"
${src}/gcc/mpfr/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --disable-shared \
    --enable-static \
    --with-gmp=$PREFIX
echo "Configure MPFR completed."
make -j1 && make install
echo "Build MPFR completed."

# Build MPC
cd $BUILD_TEMP/build-gnu-mpc
echo "Start to Configure MPC"
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

# Build ISL
cd $BUILD_TEMP/build-gnu-isl
echo "Start to Configure ISL"
${src}/gcc/isl/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --disable-shared \
    --enable-static \
    --with-gmp-prefix=$PREFIX
echo "Configure ISL completed."
make -j1 && make install
echo "Build ISL completed."

# 设定 PREFIX 与 WORKDIR（替换为你的实际路径变量）
WORKDIR="${GITHUB_WORKSPACE:-$(pwd)}"
PREFIX="$WORKDIR/build/ubuntu-tools/mingw64"

echo "PREFIX=$PREFIX"
echo "PKG_CONFIG_PATH(before)=$PKG_CONFIG_PATH"

# 将你 install 的 pkgconfig 目录临时放到前面（不永久修改）
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
echo "PKG_CONFIG_PATH(after)=$PKG_CONFIG_PATH"

echo "Check pkg-config for isl:"
pkg-config --modversion isl || echo "pkg-config can't find isl"

echo "pkg-config cflags/libs for isl:"
pkg-config --cflags isl || true
pkg-config --libs isl || true

echo "List pkgconfig files under PREFIX:"
ls -la "$PREFIX/lib/pkgconfig" || true

echo "List installed lib files:"
ls -la "$PREFIX/lib" | egrep "libisl|isl" || true

echo "--- search symbol in libisl ---"
if [ -f "$PREFIX/lib/libisl.a" ]; then
  nm -g "$PREFIX/lib/libisl.a" | grep isl_set_copy_basic_set || echo "symbol not found in libisl.a"
fi
if [ -f "$PREFIX/lib/libisl.so" ]; then
  nm -D "$PREFIX/lib/libisl.so" | grep isl_set_copy_basic_set || echo "symbol not found in libisl.so"
fi

# Build Cloog
cd $BUILD_TEMP/build-gnu-cloog
echo "Start to Configure Cloog"
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