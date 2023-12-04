#!/bin/bash

set -e

DEFAULT_PREFIX="$(pwd)/libpq-install"
VERSION="${1:-15.5}"
PREFIX="${2:-$DEFAULT_PREFIX}"
AC_VERSION="$(autoconf --version | head -n 1 | rev | cut -d ' ' -f 1 | rev)"

echo "[1/6] Downloading..."

wget -qO pq.tgz --show-progress "https://ftp.postgresql.org/pub/source/v$VERSION/postgresql-$VERSION.tar.gz"
tar -xzf pq.tgz
mv "postgresql-$VERSION" pq
rm -f pq.tgz

echo "[2/6] Patching..."

cd pq

sed -E -i "s/^m4_if\(m4_defn\(\[m4_PACKAGE_VERSION\]\), \[[^\]+\]/LT_INIT\n#m4_if(m4_defn([m4_PACKAGE_VERSION]), [$AC_VERSION]/gm;t" configure.ac
sed -E -i "s/Untested combinations of 'autoconf' and PostgreSQL/#Untested combinations of 'autoconf' and PostgreSQL/gm;t" configure.ac
sed -E -i 's/recommended.  You can remove the check from/#recommended.  You can remove the check from/gm;t' configure.ac
sed -E -i 's/your responsibility whether the result works or not/#your responsibility whether the result works or not/gm;t' configure.ac
sed -E -i 's/^LT_INIT$//gm;t' configure.ac
sed -E -i 's/^(AC_DEFINE_UNQUOTED\(CONFIGURE_ARGS, [^\n]+)/\1\nAM_INIT_AUTOMAKE/gm;t' configure.ac

cp -f GNUmakefile.in GNUmakefile.am
touch AUTHORS ChangeLog NEWS

echo "[3/6] Bootstrapping..."

aclocal -I config
libtoolize --force --copy
autoheader
automake --add-missing --copy -Wnone
autoconf -Wnone

echo "[4/6] Configuring..."

./configure --enable-static --prefix="$PREFIX"

echo "[5/6] Building..."

make

echo "[6/6] Installing..."

make install
