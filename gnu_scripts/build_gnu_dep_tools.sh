WORKDIR="${GITHUB_WORKSPACE:-$(pwd)}"
export PREFIX="$WORKDIR/build/ubuntu-tools/mingw64"
export BUILD_TEMP="$WORKDIR/build/build-temp"
export SRC_DIR="$WORKDIR/build/src"
export TARGET=x86_64-w64-mingw32
export BUILD=x86_64-pc-linux-gnu
export HOST=x86_64-pc-linux-gnu
export PATH=$PATH:$PREFIX/bin

cd $BUILD_TEMP
for d in build-gnu-gmp build-gnu-mpfr build-gnu-mpc build-gnu-isl; do
    [ -d "$d" ] && rm -rf "$d"
done
mkdir -p build-gnu-gmp build-gnu-mpfr build-gnu-mpc build-gnu-isl
echo "mkdir build-gnu-gmp build-gnu-mpfr build-gnu-mpc build-gnu-isl"


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

# Verify GMP installation
if [ -f "$PREFIX/lib/libgmp.a" ]; then
    echo "GMP installation verified successfully."
else
    echo "GMP installation verification failed." >&2
fi

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

# Verify MPFR installation
if [ -f "$PREFIX/lib/libmpfr.a" ]; then
    echo "MPFR installation verified successfully."
else
    echo "MPFR installation verification failed." >&2
fi

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

# Verify MPC installation
if [ -f "$PREFIX/lib/libmpc.a" ]; then
    echo "MPC installation verified successfully."
else
    echo "MPC installation verification failed." >&2
fi

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

# Verify ISL installation
if [ -f "$PREFIX/lib/libisl.a" ]; then
    echo "ISL installation verified successfully."
else
    echo "ISL installation verification failed." >&2
fi