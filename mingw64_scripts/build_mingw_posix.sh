WORKDIR="${GITHUB_WORKSPACE:-$(pwd)}"
export PREFIX="$WORKDIR/build/mingw64"
export BUILD_TEMP="$WORKDIR/build/build-temp"
export SRC_DIR="$WORKDIR/build/src"
export OUTPUT_DIR="$WORKDIR/build/ubuntu-tools/mingw64"
export TARGET=x86_64-w64-mingw32
export BUILD=x86_64-pc-linux-gnu
export HOST=x86_64-w64-mingw32
export PATH=$PATH:$OUTPUT_DIR/bin

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

mkdir -p $BUILD_TEMP/build-mingw-winpthreads $BUILD_TEMP/build-mingw-winstorecompat
echo "mkdir build-mingw-winpthreads build-mingw-winstorecompat"

mingw64_src=$(realpath --relative-to="${BUILD_TEMP}/build-mingw-winpthreads" "${SRC_DIR}/mingw-w64")

cd $BUILD_TEMP/build-mingw-winpthreads
${mingw64_src}/mingw-w64-libraries/winpthreads/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$HOST \
    --enable-shared \
    --enable-static \
    --with-gnu-ld
echo "Configure winpthreads completed."
make -j1 && make install
echo "Build winpthreads completed."

cd $BUILD_TEMP/build-mingw-winstorecompat
${mingw64_src}/mingw-w64-libraries/winstorecompat/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$HOST
echo "Configure winstorecompat completed."
make -j1 && make install
echo "Build winstorecompat completed."