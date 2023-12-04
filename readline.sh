#!/bin/bash

set -e

DEFAULT_PREFIX="$(pwd)/readline-install"
DEFAULT_TARGET="$(uname -m)-linux-gnu"

VERSION="${1:-8.2}"
PREFIX="${2:-$DEFAULT_PREFIX}"
TARGET="${3:-$DEFAULT_TARGET}"

echo "[1/4] Downloading..."

wget -qO readline.tgz "https://ftp.gnu.org/gnu/readline/readline-$VERSION.tar.gz"
tar -xzf readline.tgz
mv "readline-$VERSION" readline
rm -f readline.tgz
cd readline

echo "[2/4] Configuring..."

./configure --enable-static --prefix="$PREFIX" --host="$TARGET"

echo "[3/4] Building..."

make

echo "[4/4] Installing..."

make install
