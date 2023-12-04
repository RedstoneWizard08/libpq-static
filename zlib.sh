#!/bin/bash

set -e

DEFAULT_PREFIX="$(pwd)/zlib-install"
DEFAULT_TARGET="$(uname -m)-linux-gnu"

VERSION="${1:-1.2.13}"
PREFIX="${2:-$DEFAULT_PREFIX}"
TARGET="${3:-$DEFAULT_TARGET}"

ROOT="$(realpath "$(dirname "$0")")"

echo "[1/4] Downloading..."

wget -qO zlib.tgz "https://www.zlib.net/fossils/zlib-$VERSION.tar.gz"
tar -xzf zlib.tgz
mv "zlib-$VERSION" zlib
rm -f zlib.tgz
cd zlib

echo "[2/4] Configuring..."

mkdir build
cd build
cmake .. -G Ninja -DCMAKE_TOOLCHAIN_FILE="$ROOT/cmake/$TARGET.cmake"  -DCMAKE_INSTALL_PREFIX="$PREFIX"

echo "[3/4] Building..."

ninja

echo "[4/4] Installing..."

ninja install
