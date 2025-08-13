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