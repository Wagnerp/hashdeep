#!/bin/sh
cat <<EOF
****************************************************************
Configuring OS X for cross-compiling multi-threaded 32-bit and
		 64-bit Windows programs with mingw.
****************************************************************

This script will configure your OS X system to cross compile with
the Mingw-w64 compilers. It requires:

1. OS X up and running.

2. This script. Put it in your home directory.

3. You will be prompted for your password during the process.

press any key to continue...
EOF
read

#if [ $USER != "root" ]; then
#  echo ERROR: You must run this script as root.
#  exit 1
#fi

if [ ! `uname` == 'Darwin' ]; then
  echo ERROR: This script is intended for OS X systems.
  echo Once you go Mac, you never go back...
  exit 1
fi

echo Ready to install.
echo
echo Installing Mingw-w64 cross compiler packages...
echo For information, please see:
echo http://mingw-w64.sourceforge.net/download.php#automated-builds
echo
I686_DATE=20130531
I686_FILENAME=mingw-w32-bin_i686-darwin_$I686_DATE.tar.bz2
if [ ! -r $I686_FILENAME ]; then
    echo Downloading 32-bit cross compiler
    curl -L "http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Automated%20Builds/mingw-w32-bin_i686-darwin_$I686_DATE.tar.bz2/download" > $I686_FILENAME
fi

X64_DATE=20130615
X64_FILENAME=mingw-w64-bin_i686-darwin_$X64_DATE.tar.bz2
if [ ! -r $X64_FILENAME ]; then
    echo Downloading 64-bit cross compiler
    curl -L "http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Automated%20Builds/mingw-w64-bin_i686-darwin_$X64_DATE.tar.bz2/download" > $X64_FILENAME
fi

echo
echo Expanding files
echo
rm -rf i686-w64-mingw32 x86_64-w64-mingw32
mkdir i686-w64-mingw32 x86_64-w64-mingw32
cd i686-w64-mingw32
tar jxf ../$I686_FILENAME
cd ../x86_64-w64-mingw32
tar jxf ../$X64_FILENAME
cd ..

echo
echo Moving files into position. Please enter your password at the prompt:
echo
sudo mkdir -p /usr/local
sudo mv i686-w64-mingw32 x86_64-w64-mingw32 /usr/local

echo
echo Getting pthreads...
echo
if [ ! -r pthreads-w32-2-9-1-release.tar.gz ]; then
  wget ftp://sourceware.org/pub/pthreads-win32/pthreads-w32-2-9-1-release.tar.gz
fi
/bin/rm -rf pthreads-w32-2-9-1-release
tar xfz pthreads-w32-2-9-1-release.tar.gz

echo
echo Compiling pthreads...
echo
pushd pthreads-w32-2-9-1-release
  for CROSS in i686-w64-mingw32 x86_64-w64-mingw32
  do
    PATH=/usr/local/$CROSS/bin:$PATH make CROSS=$CROSS- CFLAGS="-DHAVE_STRUCT_TIMESPEC -I." clean GC-static
    sudo install implement.h need_errno.h pthread.h sched.h semaphore.h /usr/local/$CROSS/mingw/include/
    if [ $? != 0 ]; then
      echo "Unable to install pthreads header for $CROSS"
      exit 1
    fi
    sudo install *.a /usr/local/$CROSS/mingw/lib/
    if [ $? != 0 ]; then
      echo "Unable to install pthreads library for $CROSS"
      exit 1
    fi
    make clean
  done
popd
echo
echo Successfully installed pthreads.


## RBF - Add new compilers to $PATH in .profile
## RBF - Do we need to update/remove the compiler flags for cross compilation?


echo ================================================================
echo ================================================================
echo
echo Installation complete!
echo You should now be able to cross compile the programs.
echo $ sh bootstrap.sh
echo $ ./configure
echo $ make world
