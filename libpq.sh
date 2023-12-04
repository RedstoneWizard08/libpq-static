#!/bin/bash

set -e

DEFAULT_PREFIX="$(pwd)/libpq-install"
DEFAULT_TARGET="$(uname -m)-linux-gnu"

VERSION="${1:-15.5}"
PREFIX="${2:-$DEFAULT_PREFIX}"
TARGET="${3:-$DEFAULT_TARGET}"

AC_VERSION="$(autoconf --version | head -n 1 | rev | cut -d ' ' -f 1 | rev)"

echo "[PREP] Cleaning..."

[[ -d "pq" ]] && rm -rf pq
[[ -d "readline" ]] && rm -rf readline
[[ -d "ncurses" ]] && rm -rf ncurses
[[ -d "zlib" ]] && rm -rf zlib

echo "[1/7] Building dependencies (readline, ncurses, and zlib)..."

bash ./readline.sh 8.2 "$PREFIX" "$TARGET"
bash ./ncurses.sh 6.4 "$PREFIX" "$TARGET"
bash ./zlib.sh 1.2.13 "$PREFIX" "$TARGET"

echo "[2/7] Downloading..."

wget -qO pq.tgz --show-progress "https://ftp.postgresql.org/pub/source/v$VERSION/postgresql-$VERSION.tar.gz"
tar -xzf pq.tgz
mv "postgresql-$VERSION" pq
rm -f pq.tgz

echo "[3/7] Patching..."

cd pq

sed -E -i "s/^m4_if\(m4_defn\(\[m4_PACKAGE_VERSION\]\), \[[^\]+\]/LT_INIT\n#m4_if(m4_defn([m4_PACKAGE_VERSION]), [$AC_VERSION]/gm;t" configure.ac
sed -E -i "s/Untested combinations of 'autoconf' and PostgreSQL/#Untested combinations of 'autoconf' and PostgreSQL/gm;t" configure.ac
sed -E -i 's/recommended.  You can remove the check from/#recommended.  You can remove the check from/gm;t' configure.ac
sed -E -i 's/your responsibility whether the result works or not/#your responsibility whether the result works or not/gm;t' configure.ac
sed -E -i 's/^LT_INIT$//gm;t' configure.ac
sed -E -i 's/^(AC_DEFINE_UNQUOTED\(CONFIGURE_ARGS, [^\n]+)/\1\nAM_INIT_AUTOMAKE/gm;t' configure.ac

cp -f GNUmakefile.in GNUmakefile.am
touch AUTHORS ChangeLog NEWS

echo "[4/7] Bootstrapping..."

aclocal -I config
libtoolize --force --copy
autoheader
automake --add-missing --copy -Wnone
autoconf -Wnone

echo "[5/7] Configuring..."

./configure \
    --enable-static \
    --prefix="$PREFIX" \
    --host="$TARGET" \
    --with-libraries="$PREFIX/lib" \
    --with-includes="$PREFIX/include"

echo "[6/7] Building..."

make

echo "[7/7] Installing..."

make install
