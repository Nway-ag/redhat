#!/bin/bash

TOP=$PWD
TOP_SRCDIR=$TOP/ltp
SYSROOT=$TOP/ltp-install
TOP_BUILDDIR=$TOP/ltp-build
test -d "$TOP_BUILDDIR" || mkdir -p "$TOP_BUILDDIR"

if [ -f $TOP_SRCDIR/.git/config ]; then
	echo "LOG: ltp has been cloned in $TOP_SRCDIR"
	pushd $TOP_SRCDIR; git pull  > /dev/null 2>&1; make autotools; popd
else
	cd $TOP && git clone https://github.com/linux-test-project/ltp  --depth=1
	pushd $TOP_SRCDIR; make autotools; popd
fi

pushd "$TOP_BUILDDIR" && "$TOP_SRCDIR/configure"
OUT_OF_BUILD_TREE_DIR=$TOP_BUILDDIR
make -j`nproc` \
	-C "$OUT_OF_BUILD_TREE_DIR" \
	-f "$TOP_SRCDIR/Makefile" \
	"top_srcdir=$TOP_SRCDIR" \
	"top_builddir=$OUT_OF_BUILD_TREE_DIR"

make \
	-C "$OUT_OF_BUILD_TREE_DIR" \
	-f "$TOP_SRCDIR/Makefile" \
	"top_srcdir=$TOP_SRCDIR" \
	"top_builddir=$OUT_OF_BUILD_TREE_DIR" \
	"DESTDIR=$SYSROOT" \
	SKIP_IDCHECK=1 install
popd
