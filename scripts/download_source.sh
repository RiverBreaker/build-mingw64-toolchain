#!/usr/bin/env bash
set -euo pipefail

# Prefer environment var set by Actions; otherwise use repo root
WORKDIR="${GITHUB_WORKSPACE:-$(pwd)}"
SRC_DIR="$WORKDIR/build/src"

echo "Using WORKDIR: $WORKDIR"
echo "Preparing source dir: $SRC_DIR"

mkdir -p "$SRC_DIR"
cd "$SRC_DIR"

# Clone the Mingw-w64 repository
echo "Cloning Mingw-w64 repository..."
if [ ! -d mingw-w64 ]; then
  git clone https://github.com/mingw-w64/mingw-w64.git mingw-w64
fi
cd mingw-w64
git fetch --tags --prune
git checkout tags/v13.0.0 -b v13.0.0 || git checkout v13.0.0 || true
cd ..

# Clone the Binutils repository
echo "Cloning Binutils repository..."
if [ ! -d binutils ]; then
  git clone https://github.com/bminor/binutils-gdb.git binutils
fi
cd binutils
git fetch --tags --prune
git checkout tags/binutils-2_40 -b binutils-2_40 || git checkout binutils-2_40 || true
cd ..

# Clone the GCC repository
echo "Cloning GCC repository..."
if [ ! -d gcc ]; then
  git clone https://github.com/gcc-mirror/gcc.git gcc
fi
cd gcc
git fetch --tags --prune
git checkout tags/releases/gcc-13.2.0 -b releases/gcc-13.2.0 || git checkout releases/gcc-13.2.0 || true

# Download prerequisites for GCC (this requires network/wget/curl)
if [ -x contrib/download_prerequisites ]; then
  echo "Running contrib/download_prerequisites..."
  ./contrib/download_prerequisites
else
  echo "Warning: contrib/download_prerequisites not found or not executable yet; ensure you run this inside gcc source dir."
fi
cd ..


# Download Libiconv
echo "Downloading Libiconv source code..."
if [ ! -d libiconv ]; then
  wget -c https://ftp.gnu.org/gnu/libiconv/libiconv-1.18.tar.gz
  tar -xzf libiconv-1.18.tar.gz
  mv libiconv-1.18 libiconv
  rm -f libiconv-1.18.tar.gz
fi

# Download M4
echo "Downloading M4 source code..."
if [ ! -d m4 ]; then
  wget -c https://ftp.gnu.org/gnu/m4/m4-1.4.20.tar.gz
  tar -xzf m4-1.4.20.tar.gz
  mv m4-1.4.20 m4
  rm -f m4-1.4.20.tar.gz
fi

# Download Libtool
echo "Downloading Libtool source code..."
if [ ! -d libtool ]; then
  wget -c https://ftp.gnu.org/gnu/libtool/libtool-2.5.4.tar.gz
  tar -xzf libtool-2.5.4.tar.gz
  mv libtool-2.5.4 libtool
  rm -f libtool-2.5.4.tar.gz
fi

echo "All downloads completed."
