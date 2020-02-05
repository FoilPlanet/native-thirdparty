#!/bin/bash
# Run this from within a bash shell
#
# ANDROID_NDK_HOME: default NDK home

DEFAULT_NDK=/build/android-ndk-r17b
ANDROID_NDK=${ANDROID_NDK_HOME:-$DEFAULT_NDK}

ANDROID_ABI=${1:-"arm64-v8a"}
API_LEVEL=android-24
BUILD_PATH=build-${ANDROID_ABI}

MAKE_PROGRAM=`which make`

# Detect OS
HOST_OS=`uname -s`
HOST_ARCH=`uname -m`
if [ $HOST_OS == 'Linux' ]; then
  HOST_SYSTEM=linux-$HOST_ARCH
elif [ $HOST_OS == 'Darwin' ]; then
  HOST_SYSTEM=darwin-$HOST_ARCH
fi

# Set NDK platform
case $ANDROID_ABI in
  armeabi-v7a)
    PLATFORM=$ANDROID_NDK/platforms/${API_LEVEL}/arch-arm
    ANDROID_TARGET="arm-linux-androideabi"
    ANDROID_TOOLCHAIN_NAME="arm-linux-androideabi-4.9"
    CROSS_PREFIX=$ANDROID_NDK/toolchains/$ANDROID_TOOLCHAIN_NAME/prebuilt/$HOST_SYSTEM/bin/$ANDROID_TARGET-
    APP_CFLAGS="-DHAVE_NEON=1"
    # APP_CFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=neon -DHAVE_NEON=1"
    CONFIG_PARM="--host=arm-linux"
    ;;
  arm64-v8a)
    PLATFORM=$ANDROID_NDK/platforms/${API_LEVEL}/arch-arm64
    ANDROID_TARGET="aarch64-linux-android"
    ANDROID_TOOLCHAIN_NAME="aarch64-linux-android-4.9"
    CROSS_PREFIX=$ANDROID_NDK/toolchains/$ANDROID_TOOLCHAIN_NAME/prebuilt/$HOST_SYSTEM/bin/$ANDROID_TARGET-
    APP_CFLAGS="-DHAVE_NEON=1"
    # APP_CFLAGS="-mcpu=cortex-a15 -mfpu=neon-vfpv4 -mfloat-abi=softfp -DHAVE_NEON=1"
    CONFIG_PARM="--host=aarch64-linux"
    ;;
  x86)
    PLATFORM=$ANDROID_NDK/platforms/${API_LEVEL}/arch-x86
    ANDROID_TARGET="i686-linux-android"
    ANDROID_TOOLCHAIN_NAME="x86-4.9"
    CROSS_PREFIX=$ANDROID_NDK/toolchains/$ANDROID_TOOLCHAIN_NAME/prebuilt/$HOST_SYSTEM/bin/$ANDROID_TARGET-
    # APP_CFLAGS="-fprefetch-loop-arrays -fno-short-enums -finline-limit=300 -fomit-frame-pointer -mssse3 -mfpmath=sse -masm=intel -DHAVE_NEON=1"
    CONFIG_PARM="--host=x86-linux"
    ;;
  x86_64)
    PLATFORM=$ANDROID_NDK/platforms/${API_LEVEL}/arch-x86_64
    ANDROID_TARGET="x86_64-linux-android"
    ANDROID_TOOLCHAIN_NAME="x86_64-4.9"
    CROSS_PREFIX=$ANDROID_NDK/toolchains/$ANDROID_TOOLCHAIN_NAME/prebuilt/$HOST_SYSTEM/bin/$ANDROID_TARGET-
    APP_CFLAGS=""
    CONFIG_PARM="--host=x86_64-linux"
    ;;
  *)
    echo "Unknown ABI type $ANDROID_ABI"
    exit 1
    ;;
esac

APP_CPPFLAGS="$APP_CPPFLAGS -std=c++11 -fexceptions"
APP_CFLAGS="$APP_CFLAGS -I$ANDROID_NDK/sysroot/usr/include -I$ANDROID_NDK/sysroot/usr/include/$ANDROID_TARGET"
APP_LDFLAGS="$APP_LDFLAGS -nostdlib"

# ----------------------------------------------------------------------------
# Build with autoconf and makefile
# ----------------------------------------------------------------------------                                                       \

PREFIX=`pwd`/$BUILD_PATH
SOURCE=x264
# SYSROOT=$ANDROID_NDK/sysroot
SYSROOT=$PLATFORM

echo "--- Configure $ANDROID_ABI in '$BUILD_PATH' ---"
mkdir -p ${BUILD_PATH} || exit 1
cd $SOURCE

CONFIG_PARM="$CONFIG_PARM
  --prefix=$PREFIX
  --cross-prefix=$CROSS_PREFIX
  --enable-pic
  --enable-static
  --enable-strip
  --disable-cli
  --disable-asm
  --sysroot=$SYSROOT
"
# ./configure $CONFIG_PARM --extra-cflags="$APP_CFLAGS" --extra-ldflags="$APP_LDFLAGS"
./configure $CONFIG_PARM --extra-cflags="$APP_CFLAGS"

echo ""
echo "Building in '$BUILD_PATH'..."
make clean
make STRIP= -j4 || exit 1

echo ""
echo "Installinng to '$PREFIX'..."
make STRIP= install || exit 1

echo "--- $BUILD_PATH ---"
echo "done."



