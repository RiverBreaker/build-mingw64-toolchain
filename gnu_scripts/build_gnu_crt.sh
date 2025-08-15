WORKDIR="${GITHUB_WORKSPACE:-$(pwd)}"
export PREFIX="$WORKDIR/build/ubuntu-tools/mingw64"
export BUILD_TEMP="$WORKDIR/build/build-temp"
export SRC_DIR="$WORKDIR/build/src"
export TARGET=x86_64-w64-mingw32
export BUILD=x86_64-pc-linux-gnu
export HOST=x86_64-pc-linux-gnu
export PATH=$PATH:$PREFIX/bin

cd $BUILD_TEMP

# Check if gcc stage1 is available
if [ ! -x "$PREFIX/bin/$TARGET-gcc" ]; then
    echo "Error: $TARGET-gcc not found. Cannot build CRT." >&2
    exit 1
fi

# Clean and create CRT build directory
if [ -d build-gnu-crt ]; then
    rm -rf build-gnu-crt
    echo "remove build-gnu-crt"
fi
mkdir -p build-gnu-crt
echo "mkdir build-gnu-crt"

# Build crt
echo "Configure gnu mingw crt starting..."
cd $BUILD_TEMP/build-gnu-crt
AR=$TARGET-ar \
AS=$TARGET-as \
CC=$TARGET-gcc \
CXX=$TARGET-g++ \
DLLTOOL=$TARGET-dlltool \
RANLIB=$TARGET-ranlib \
$SRC_DIR/mingw-w64/mingw-w64-crt/configure \
    --prefix=$PREFIX/$TARGET \
    --build=$BUILD \
    --host=$HOST \
    --disable-w32api \
    --disable-lib32 \
    --enable-lib64 \
    --enable-private-exports
echo "Configure crt completed."
make -j1 && make install
echo "Build crt completed."

# Verify crt installation
if [ -d "$PREFIX/$TARGET/lib" ]; then
    echo "CRT installation verified successfully."
else
    echo "CRT installation verification failed." >&2
fi