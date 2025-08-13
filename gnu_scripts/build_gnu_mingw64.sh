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

mingw64_src=$(realpath --relative-to="${BUILD_TEMP}/build-gnu-headers" "${SRC_DIR}/mingw-w64")

# Build headers
cd $BUILD_TEMP/build-gnu-headers
${mingw64_src}/mingw-w64-headers/configure \
    --prefix=$PREFIX/$TARGET \
    --build=$BUILD \
    --target=$TARGET \
    --enable-idl \
    --enable-secure-api \
    --with-widl=$PREFIX/bin 
echo "Configure headers completed."
make -j1 && make install
echo "Build headers completed."
mkdir $PREFIX/$TARGET/mingw
ls -s ../include $PREFIX/$TARGET/mingw

# Build gendef
cd $BUILD_TEMP/build-gnu-gendef
${mingw64_src}/mingw-w64-tools/configure \
    --prefix=$PREFIX \
    --build=$BUILD
echo "Configure gendef completed."
make -j1 && make install
echo "Build gendef completed."

# Build genidl
cd $BUILD_TEMP/build-gnu-genidl
${mingw64_src}/mingw-w64-tools/configure \
    --prefix=$PREFIX \
    --build=$BUILD
echo "Configure genidl completed."
make -j1 && make install
echo "Build genidl completed."

# Build widl
cd $BUILD_TEMP/build-gnu-widl
${mingw64_src}/mingw-w64-tools/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --target=$TARGET 
echo "Configure widl completed."
make -j1 && make install
echo "Build widl completed."

# Build crt
cd $BUILD_TEMP/build-gnu-crt
AR='$TARGET-ar' \
AS='$TARGET-as' \
CC='$TARGET-gcc' \
CXX='$TARGET-g++' \
DLLTOOL='$TARGET-dlltool' \
RANLIB='$TARGET-ranlib' \
${mingw64_src}/mingw-w64-crt/configure \
    --prefix=$PREFIX/$TARGET \
    --build=$BUILD \
    --disable-w32api \
    --disable-lib32 \
    --enable-lib64 \
    --enable-private-exports
echo "Configure crt completed."
make -j1 && make install
echo "Build crt completed."