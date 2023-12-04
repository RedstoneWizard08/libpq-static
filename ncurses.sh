#!/bin/bash

set -e

DEFAULT_PREFIX="$(pwd)/ncurses-install"
DEFAULT_TARGET="$(uname -m)-linux-gnu"

VERSION="${1:-6.4}"
PREFIX="${2:-$DEFAULT_PREFIX}"
TARGET="${3:-$DEFAULT_TARGET}"

echo "[1/4] Downloading..."

wget -qO ncurses.tgz "https://ftp.gnu.org/gnu/ncurses/ncurses-$VERSION.tar.gz"
tar -xzf ncurses.tgz
mv "ncurses-$VERSION" ncurses
rm -f ncurses.tgz
cd ncurses

echo "[2/4] Configuring..."

./configure --enable-static --without-progs --prefix="$PREFIX" --host="$TARGET"

echo "[3/4] Building..."

make

echo "[4/4] Installing..."

make install
