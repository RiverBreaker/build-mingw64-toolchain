#!/bin/bash

cd ${{ github.workspace }}/build/src
# Clone the Mingw-w64 repository
echo "Cloning Mingw-w64 repository..."
git clone https://github.com/mingw-w64/mingw-w64.git mingw-w64
cd mingw-w64 && git checkout tags/v13.0.0 -b v13.0.0 && cd ..
echo "Clone Mingw-w64 repository completed."
# Clone the Binutils repository
echo "Cloning Binutils repository..."
git clone https://github.com/bminor/binutils-gdb.git binutils
cd binutils && git checkout tags/binutils-2_40 -b binutils-2_40 && cd ..
echo "Clone Binutils repository completed."
# Clone the GCC repository
echo "Cloning GCC repository..."
git clone https://github.com/gcc-mirror/gcc.git gcc
cd gcc && git checkout tags/releases/gcc-13.2.0 -b releases/gcc-13.2.0
contrib/download_prerequisites
cd ..
echo "Clone GCC repository completed."
# Download the Cloog repository
echo "Downloading Cloog repository..."
wget http://www.bastoul.net/cloog/pages/download/cloog-0.18.4.tar.gz \
&& tar -xzf cloog-0.18.4.tar.gz \
&& mv cloog-0.18.4 cloog \
&& rm cloog-0.18.4.tar.gz
echo "Download Cloog repository completed."
# Download the Libiconv repository
echo "Downloading Libiconv source code..."
wget https://ftp.gnu.org/gnu/libiconv/libiconv-1.18.tar.gz \
&& tar -xzf libiconv-1.18.tar.gz \
&& mv libiconv-1.18 libiconv \
&& rm libiconv-1.18.tar.gz
echo "Download Libiconv source code completed."
# Download the M4 repository
echo "Downloading M4 source code..."
wget https://ftp.gnu.org/gnu/m4/m4-1.4.20.tar.gz \
&& tar -xzf m4-1.4.20.tar.gz \
&& mv m4-1.4.20 m4 \
&& rm m4-1.4.20.tar.gz
echo "Download M4 source code completed."
# Download the Libtool repository
echo "Downloading Libtool source code..."
wget https://ftp.gnu.org/gnu/libtool/libtool-2.5.4.tar.gz \
&& tar -xzf libtool-2.5.4.tar.gz \
&& mv libtool-2.5.4 libtool \
&& rm libtool-2.5.4.tar.gz
echo "Download Libtool source code completed."
