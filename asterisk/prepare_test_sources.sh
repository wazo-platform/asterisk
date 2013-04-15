#!/bin/sh
VER=$(cat ASTERISK-VERSION)

rm -rf tmp
mkdir tmp
cd tmp
tar xzf ../tarballs/asterisk_${VER}+dfsg.orig.tar.gz
cd asterisk-${VER}
ln -s ../../patches/ patches
quilt push -a
if [ $? -eq 0 ]; then
    pwd
    quilt pop -a
    for patches in $(quilt unapplied); do
        quilt push && quilt refresh
    done
fi
