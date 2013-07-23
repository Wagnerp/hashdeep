#!/bin/sh
cat <<EOF
****************************************************************
Configuring OS X for cross-compiling multi-threaded 32-bit and
		 64-bit Windows programs with mingw.
****************************************************************

This script will configure your OS X system to compile with
mingw32 and 64.  It requires:

1. OS X up and running.

2. This script. Put it in your home directory.

3. Root access. This script must be run as root. You can do that 
   by typing:
          sudo sh CONFIGURE_CROSS.sh

press any key to continue...
EOF
read

if [ $USER != "root" ]; then
  echo ERROR: You must run this script as root.
  exit 1
fi

if [ ! `uname` == 'Darwin' ]; then
  echo ERROR: This script is intended for OS X systems.
  echo Once you go Mac, you never go back.
  exit 1
fi

echo Attempting to install tools necessary to build md5deep...
echo Installing wget...
yum -y install wget
echo Successfully installed wget.

echo Installing Fedora Win32 and Win64 cross compiler packages...
echo For information, please see:
echo http://fedoraproject.org/wiki/MinGW/CrossCompilerFramework
if [ ! -d /etc/yum.repos.d ]; then
  echo ERROR: /etc/yum.repos.d does not exist. This is very bad. I quit.
  exit 1
fi
if [ ! -r /etc/yum.repos.d/fedora-cross.repo ] ; then
  if wget --directory-prefix=/etc/yum.repos.d  http://build1.openftd.org/fedora-cross/fedora-cross.repo ; then
    echo Successfully downloaded repository list for cross compilers.
  else
    echo ERROR: Could not download the repository list cross compilers.
    exit 1
  fi
fi

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
    make CROSS=$CROSS- CFLAGS="-DHAVE_STRUCT_TIMESPEC -I." clean GC-static
    install implement.h need_errno.h pthread.h sched.h semaphore.h /usr/$CROSS/sys-root/mingw/include/
    if [ $? != 0 ]; then
      echo "Unable to install include files for $CROSS"
      exit 1
    fi
    install *.a /usr/$CROSS/sys-root/mingw/lib/
    if [ $? != 0 ]; then
      echo "Unable to install library for $CROSS"
      exit 1
    fi
    make clean
  done
popd
echo
echo Successfully installed pthreads.

echo ================================================================
echo ================================================================
echo
echo Installation complete!
echo You should now be able to cross compile the programs.
echo $ sh bootstrap.sh
echo $ ./configure
echo $ make world
