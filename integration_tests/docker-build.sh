#!/bin/bash

set -ex

if [ -d "$SRCDIR" ]; then
    PKGDIR=${SRCDIR}/..
else
    PKGDIR=$(cd $(dirname $0); pwd)/../..
fi

if [ -f ${PKGDIR}/Packages ]; then
    rm -f Packages *.deb
    ln -f ${PKGDIR}/{Packages,*.deb} . || ln -sf ${PKGDIR}/{Packages,*.deb} .
    sed -e "s@RUN echo@COPY Packages *.deb /var/tmp/\nRUN echo \"deb [trusted=yes] file:///var/tmp ./\" > /etc/apt/sources.list.d/wazo-dev.list \&\& echo@" < ../Dockerfile > Dockerfile
    docker build -t wazoplatform/asterisk .
    rm -f Dockerfile Packages *.deb
fi

# docker-build.sh ends here
