#!/bin/sh

readonly CLANG_CC=$(which clang)
readonly CLANG_CXX=$(which clang++)
if [[ ! -f $CLANG_CC ]]; then
  echo "clang was not found: $CLANG_CC"
  exit 1
fi
if [[ ! -f $CLANG_CXX ]]; then
  echo "clang++ was not found: $CLANG_CXX"
  exit 1
fi

readonly SRCROOT=$(cd "$(dirname "$0")/../"; pwd)
readonly OPENCV_DIR="$SRCROOT/opencv"
readonly OPENCV_BUILD_DIR="$OPENCV_DIR/build"

echo "-- Fetching"
have_opencv_repo=false
if [[ -d "$OPENCV_DIR" ]]; then
  pushd "$OPENCV_DIR"
    git show-ref --verify --quiet refs/heads/master
    if [[ $? == 0 ]]; then
      have_opencv_repo=true
    fi
  popd
fi
if [[ $have_opencv_repo ]]; then
  pushd "$OPENCV_DIR"
    git pull origin
  popd
else
  git clone git@github.com:Itseez/opencv.git "$OPENCV_DIR"
fi

echo "-- Building"
mkdir -p "$OPENCV_BUILD_DIR"
pushd "$OPENCV_BUILD_DIR"
  cmake -G "Unix Makefiles" \
      -DCMAKE_BUILD_TYPE="RELEASE" \
      -DCMAKE_C_COMPILER="$CLANG_CC" \
      -DCMAKE_CXX_COMPILER="$CLANG_CXX" \
      -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
      -DCMAKE_OSX_ARCHITECTURES="x86_64" \
      "$OPENCV_DIR"
  make -j8
  echo "-- Installing"
  make install
popd

echo "-- Done"
