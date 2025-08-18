WORKDIR="${GITHUB_WORKSPACE:-$(pwd)}"
export PREFIX="$WORKDIR/build/mingw64"
export BUILD_TEMP="$WORKDIR/build/build-temp"
export SRC_DIR="$WORKDIR/build/src"
export OUTPUT_DIR="$WORKDIR/build/ubuntu-tools/mingw64"
export TARGET=x86_64-w64-mingw32
export BUILD=x86_64-pc-linux-gnu
export HOST=x86_64-w64-mingw32
export PATH=$OUTPUT_DIR/bin:$PATH

# Set cross-compiler environment variables
export CC_FOR_BUILD=gcc
export CXX_FOR_BUILD=g++
export CC=$TARGET-gcc
export CXX=$TARGET-g++
export AR=$TARGET-ar
export RANLIB=$TARGET-ranlib
export STRIP=$TARGET-strip
export AS=$TARGET-as
export DLLTOOL=$TARGET-dlltool
export SYSROOT="$PREFIX/$TARGET"
export CPPFLAGS_FOR_TARGET="-I${PREFIX}/include -I${SYSROOT}/include"
export CFLAGS_FOR_TARGET="$CPPFLAGS_FOR_TARGET"
export CXXFLAGS_FOR_TARGET="$CPPFLAGS_FOR_TARGET"
export LDFLAGS_FOR_TARGET="-L${PREFIX}/lib -L${SYSROOT}/lib"

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

if [ -d build-mingw-gcc2 ]; then
    rm -rf build-mingw-gcc2
    echo "remove build-mingw-gcc2"
fi
mkdir -p build-mingw-gcc2
echo "mkdir build-mingw-gcc2"

gcc_src=$(realpath --relative-to="${BUILD_TEMP}/build-mingw-gcc2" "${SRC_DIR}/gcc")
src=$(realpath --relative-to="${BUILD_TEMP}/build-mingw-gmp" "${SRC_DIR}")

cd $BUILD_TEMP/build-mingw-gcc2

# Verify critical header files before GCC configuration
echo "Verifying header file structure..."
if [ ! -f "$PREFIX/$TARGET/include/_mingw.h" ]; then
    echo "Error: MinGW-w64 headers not found at $PREFIX/$TARGET/include" >&2
    exit 1
fi

# Check if pthread.h will cause issues
if [ -f "$PREFIX/include/pthread.h" ] && [ ! -f "$PREFIX/$TARGET/include/process.h" ]; then
    echo "Warning: pthread.h found in $PREFIX/include but process.h missing in $PREFIX/$TARGET/include"
    echo "This may cause build failures. Ensure winpthreads is built after GCC."
fi

echo "Configure win mingw gcc/g++ starting..."
${gcc_src}/configure \
    --prefix=$PREFIX \
    --build=$BUILD \
    --host=$HOST \
    --target=$TARGET \
    --with-sysroot=$SYSROOT \
    --with-native-system-header-dir=/include \
    --with-local-prefix=$PREFIX/local \
    --disable-nls \
    --disable-lto \
    --disable-multilib \
    --disable-win32-registry \
    --disable-libstdcxx-pch \
    --disable-symvers \
    --enable-shared \
    --enable-static \
    --enable-languages=c,c++ \
    --enable-libstdcxx-debug \
    --enable-version-specific-runtime-libs \
    --enable-decimal-float=yes \
    --enable-threads=posix \
    --enable-tls \
    --enable-fully-dynamic-string \
    --with-gnu-ld \
    --with-gnu-as \
    --without-newlib \
    --with-libiconv \
    CPPFLAGS_FOR_TARGET="-I$PREFIX/$TARGET/include -I$PREFIX/include" \
    LDFLAGS_FOR_TARGET="-L$PREFIX/$TARGET/lib -L$PREFIX/lib"

# Note: We intentionally disable in-tree ISL by not referencing it, to avoid configure-isl needing gmp.h
# If Graphite is desired later, ensure system ISL is used and available, then add: --with-isl=$PREFIX

echo "Configure gcc stage 2 done"
make -j1 V=1 all-gcc || { echo "all-gcc failed"; exit 1; }
make install-gcc || { echo "install-gcc failed"; exit 1; }

# 构建 target 的 libgcc 时把 *_FOR_TARGET 传给 make
make -j1 V=1 all-target-libgcc CPPFLAGS_FOR_TARGET="$CPPFLAGS_FOR_TARGET" \
                               CFLAGS_FOR_TARGET="$CFLAGS_FOR_TARGET" \
                               LDFLAGS_FOR_TARGET="$LDFLAGS_FOR_TARGET" || { echo "all-target-libgcc failed"; exit 1; }
make install-target-libgcc CPPFLAGS_FOR_TARGET="$CPPFLAGS_FOR_TARGET" \
                           CFLAGS_FOR_TARGET="$CFLAGS_FOR_TARGET" \
                           LDFLAGS_FOR_TARGET="$LDFLAGS_FOR_TARGET" || { echo "install-target-libgcc failed"; exit 1; }

# 若需构建 libstdc++:
make -j1 V=1 all-target-libstdc++-v3 CPPFLAGS_FOR_TARGET="$CPPFLAGS_FOR_TARGET" \
                                    CFLAGS_FOR_TARGET="$CFLAGS_FOR_TARGET" \
                                    LDFLAGS_FOR_TARGET="$LDFLAGS_FOR_TARGET" || { echo "all-target-libg++-v3 failed"; exit 1; }
make install-target-libstdc++-v3 CPPFLAGS_FOR_TARGET="$CPPFLAGS_FOR_TARGET" \
                                    CFLAGS_FOR_TARGET="$CFLAGS_FOR_TARGET" \
                                    LDFLAGS_FOR_TARGET="$LDFLAGS_FOR_TARGET" || { echo "install-target-libg++-v3 failed"; exit 1; }
echo "Build gcc stage 2 done"
if [ -x "$PREFIX/bin/$TARGET-gcc" ] && [ -x "$PREFIX/bin/$TARGET-g++" ]; then
    echo "GCC final installation verified successfully."
else
    echo "GCC final installation verification failed." >&2
fi

cd $BUILD_TEMP
if [ -d build-mingw-libiconv ]; then
    rm -rf build-mingw-libiconv
    echo "remove build-mingw-libiconv"
fi
mkdir -p build-mingw-libiconv
echo "mkdir build-mingw-libiconv"

libiconv_src=$(realpath --relative-to="${BUILD_TEMP}/build-mingw-libiconv" "${SRC_DIR}/libiconv")

cd $BUILD_TEMP/build-mingw-libiconv
echo "Configure win mingw libiconv starting..."
${libiconv_src}/configure \
    --prefix=$PREFIX/$TARGET \
    --build=$BUILD \
    --host=$HOST \
    --enable-extra-encodings \
    --enable-static \
    --disable-shared \
    --disable-nls \
    --with-gnu-ld
echo "Configure libiconv done"
make -j1 && make install
echo "Build libiconv done"
if [ -f "$PREFIX/$TARGET/lib/libiconv.a" ]; then
    echo "libiconv installation verified successfully."
else
    echo "libiconv installation verification failed." >&2
fi

# Safely copy runtime DLLs and libraries if they exist
cp -f "$PREFIX/lib/gcc/$TARGET/"*.dll "$PREFIX/bin" 2>/dev/null || true
cp -f "$PREFIX/lib/gcc/$TARGET/lib/"* "$PREFIX/lib" 2>/dev/null || true

echo "Mingw-w64 toolchain build completed successfully!"
echo "Toolchain installed in: $PREFIX"

echo "gcc/g++ localtion:"
ls $PREFIX/bin
