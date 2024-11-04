FROM debian:${DEBIAN_DISTRIBUTION}
LABEL org.opencontainers.image.authors="dev+docker@wazo.community"

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/src
RUN true && \
    apt-get -q update && \
    apt-get -q -y install apt-utils \
                          gnupg \
                          wget && \
    echo "deb http://deb.debian.org/debian-debug ${DEBIAN_DISTRIBUTION}-debug main" >> /etc/apt/sources.list.d/dbgsym.list && \
    echo "deb http://deb.debian.org/debian-debug ${DEBIAN_DISTRIBUTION}-proposed-updates-debug main" >> /etc/apt/sources.list.d/dbgsym.list && \
    echo "deb http://mirror.wazo.community/archive/ wazo-${WAZO_VERSION} main" >> /etc/apt/sources.list.d/wazo-dist.list && \
    echo "deb-src http://mirror.wazo.community/archive/ wazo-${WAZO_VERSION} main" >> /etc/apt/sources.list.d/wazo-dist.list && \
    wget http://mirror.wazo.community/wazo_current.key -O - | apt-key add - && \
    apt-get -q update && \
    apt-get -q -y install asterisk \
                          asterisk-dbgsym \
                          dpkg-dev \
                          gdb \
                          libc6-dbg \
                          wazo-libsccp \
                          wazo-libsccp-dbg && \
    apt-get -q source asterisk && \
    true

CMD ["gdb", "asterisk", "-batch", "-ex", "bt full", "-ex", "thread apply all bt", "/core", "$(find /usr/src/asterisk-* -type d -printf '-d %p ')"]
