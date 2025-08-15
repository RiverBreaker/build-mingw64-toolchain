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

# Ensure PREFIX directory exists
mkdir -p $PREFIX

cd $BUILD_TEMP
for d in build-mingw-gmp build-mingw-mpfr build-mingw-mpc build-mingw-isl; do
    [ -d "$d" ] && rm -rf "$d"
done
mkdir -p build-mingw-gmp build-mingw-mpfr build-mingw-mpc build-mingw-isl
echo "mkdir build-mingw-gmp build-mingw-mpfr build-mingw-mpc build-mingw-isl"


src=$(realpath --relative-to="${BUILD_TEMP}/build-mingw-gmp" "${SRC_DIR}")

# Build dependencies
# #
# Build GMP
cd $BUILD_TEMP/build-mingw-gmp
echo "Configure win mingw gmp starting..."
${src}/gcc/gmp/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$HOST \
    --disable-shared \
    --enable-static \
    --enable-cxx
echo "Configure GMP completed."
make -j1 && make install
echo "Build GMP completed."
if [ -f "$PREFIX/lib/libgmp.a" ]; then
    echo "GMP installation verified successfully."
else
    echo "GMP installation verification failed." >&2
fi

# Build MPFR
cd $BUILD_TEMP/build-mingw-mpfr
echo "Configure win mingw mpfr starting..."
${src}/gcc/mpfr/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$HOST \
    --disable-shared \
    --enable-static \
    --with-gmp=$PREFIX
echo "Configure MPFR completed."
make -j1 && make install
echo "Build MPFR completed."
if [ -f "$PREFIX/lib/libmpfr.a" ]; then
    echo "MPFR installation verified successfully."
else
    echo "MPFR installation verification failed." >&2
fi

# Build MPC
cd $BUILD_TEMP/build-mingw-mpc
echo "Configure win mingw mpc starting..."
${src}/gcc/mpc/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$HOST \
    --disable-shared \
    --enable-static \
    --with-mpfr=$PREFIX \
    --with-gmp=$PREFIX
echo "Configure MPC completed."
make -j1 && make install
echo "Build MPC completed."
if [ -f "$PREFIX/lib/libmpc.a" ]; then
    echo "MPC installation verified successfully."
else
    echo "MPC installation verification failed." >&2
fi

# Build ISL
cd $BUILD_TEMP/build-mingw-isl
echo "Configure win mingw isl starting..."
${src}/gcc/isl/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$HOST \
    --disable-shared \
    --enable-static \
    --with-gmp-prefix=$PREFIX
echo "Configure ISL completed."
make -j1 && make install 
echo "Build ISL completed."
if [ -f "$PREFIX/lib/libisl.a" ]; then
    echo "ISL installation verified successfully."
else
    echo "ISL installation verification failed." >&2
fi