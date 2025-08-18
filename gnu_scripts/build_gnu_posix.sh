WORKDIR="${GITHUB_WORKSPACE:-$(pwd)}"
export PREFIX="$WORKDIR/build/ubuntu-tools/mingw64"
export BUILD_TEMP="$WORKDIR/build/build-temp"
export SRC_DIR="$WORKDIR/build/src"
export TARGET=x86_64-w64-mingw32
export BUILD=x86_64-pc-linux-gnu
export HOST=x86_64-pc-linux-gnu
export PATH=$PREFIX/bin:$PATH


cd $BUILD_TEMP
for d in \
    build-gnu-headers build-gnu-gendef build-gnu-genidl \
    build-gnu-widl build-gnu-crt build-gnu-libmangle \
    build-gnu-genpeimg; do
    [ -d "$d" ] && rm -rf "$d" && echo "remove $d"
done
for d in build-gnu-winpthreads build-gnu-winstorecompat; do
    [ -d "$d" ] && rm -rf "$d" && echo "remove $d"
done

mkdir -p $BUILD_TEMP/build-gnu-winpthreads $BUILD_TEMP/build-gnu-winstorecompat
echo "mkdir build-gnu-winpthreads build-gnu-winstorecompat"

mingw64_src=$(realpath --relative-to="${BUILD_TEMP}/build-gnu-winpthreads" "${SRC_DIR}/mingw-w64")

cd $BUILD_TEMP/build-gnu-winpthreads
echo "Configure win mingw winpthteads starting..."
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

cd $BUILD_TEMP/build-gnu-winstorecompat
echo "Configure win mingw winstorecompat starting..."
${mingw64_src}/mingw-w64-libraries/winstorecompat/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$HOST
echo "Configure winstorecompat completed."
make -j1 && make install
echo "Build winstorecompat completed."