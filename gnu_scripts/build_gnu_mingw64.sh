WORKDIR="${GITHUB_WORKSPACE:-$(pwd)}"
export PREFIX="$WORKDIR/build/ubuntu-tools/mingw64"
export BUILD_TEMP="$WORKDIR/build/build-temp"
export SRC_DIR="$WORKDIR/build/src"
export TARGET=x86_64-w64-mingw32
export BUILD=x86_64-pc-linux-gnu
export HOST=x86_64-pc-linux-gnu
export PATH=$PATH:$PREFIX/bin

cd $BUILD_TEMP
if [ -d build-gnu-gcc1 ]; then
    rm -rf build-gnu-gcc1
    echo "remove build-gnu-gcc1"
fi
for d in build-gnu-headers build-gnu-gendef build-gnu-genidl build-gnu-widl build-gnu-crt; do
    [ -d "$d" ] && rm -rf "$d"
done
mkdir -p build-gnu-headers build-gnu-gendef build-gnu-genidl build-gnu-widl build-gnu-crt
echo "mkdir build-gnu-headers build-gnu-gendef build-gnu-genidl build-gnu-widl build-gnu-crt"

# Build gendef
cd $BUILD_TEMP/build-gnu-gendef
echo "Configure gnu mingw gendef starting..."
$SRC_DIR/mingw-w64/mingw-w64-tools/gendef/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$BUILD
echo "Configure gendef completed."
make -j1 && make install
echo "Build gendef completed."

# Verify gendef installation
if [ -x "$PREFIX/bin/gendef" ]; then
    echo "gendef installation verified successfully."
else
    echo "gendef installation verification failed." >&2
fi

# Build genidl
cd $BUILD_TEMP/build-gnu-genidl
echo "Configure gnu mingw genidl starting..."
$SRC_DIR/mingw-w64/mingw-w64-tools/genidl/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$BUILD
echo "Configure genidl completed."
make -j1 && make install
echo "Build genidl completed."

# Verify genidl installation
if [ -x "$PREFIX/bin/genidl" ]; then
    echo "genidl installation verified successfully."
else
    echo "genidl installation verification failed." >&2
fi

# Build widl
cd $BUILD_TEMP/build-gnu-widl
echo "Configure gnu mingw widl starting..."
$SRC_DIR/mingw-w64/mingw-w64-tools/widl/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$BUILD \
    --target=$TARGET 
echo "Configure widl completed."
make -j1 && make install
echo "Build widl completed."

# Verify widl installation
if [ -x "$PREFIX/bin/widl" ]; then
    echo "widl installation verified successfully."
else
    echo "widl installation verification failed." >&2
fi

# Build headers
cd $BUILD_TEMP/build-gnu-headers
echo "Configure gnu mingw headers starting..."
$SRC_DIR/mingw-w64/mingw-w64-headers/configure \
    --prefix=$PREFIX/$TARGET \
    --build=$BUILD \
    --target=$TARGET \
    --enable-idl 
echo "Configure headers completed."
make -j1 && make install
echo "Build headers completed."
# Ensure sysroot has mingw -> . symlink so that $sysroot/mingw/include exists
if [ -e "$PREFIX/$TARGET/mingw" ] || [ -L "$PREFIX/$TARGET/mingw" ]; then
    rm -rf "$PREFIX/$TARGET/mingw"
fi
ln -s . "$PREFIX/$TARGET/mingw"

# Verify headers installation
if [ -d "$PREFIX/$TARGET/include" ]; then
    echo "Headers installation verified successfully."
else
    echo "Headers installation verification failed." >&2
fi