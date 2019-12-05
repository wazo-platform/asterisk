#!/bin/bash

set -ex

env

if [ -f $SRCDIR/../Packages ]; then
    rm -f Packages *.deb
    ln -f $SRCDIR/../{Packages,*.deb} .
    sed -e "s@RUN echo@COPY Packages *.deb /var/tmp/\nRUN echo \"deb [trusted=yes] file:///var/tmp ./\" > /etc/apt/sources.list.d/wazo-dev.list \&\& echo@" < ../Dockerfile > Dockerfile
    docker build -t wazopbx/asterisk .
    rm -f Dockerfile Packages *.deb
else
    docker pull wazopbx/asterisk
fi

# docker-build.sh ends here
