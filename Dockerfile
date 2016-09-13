## Image to build from sources

FROM debian:jessie
MAINTAINER dev+docker@proformatique.com

ENV DEBIAN_FRONTEND noninteractive
ENV ASTERISK_VERSION 13.11.2

# Add dependencies
RUN apt-get -qq update && apt-get -qq -y install \
    apt-utils \
    build-essential \
    git \
    wget
RUN echo "deb http://mirror.xivo.io/debian/ xivo-dev main" > /etc/apt/sources.list.d/xivo.list
RUN wget http://mirror.xivo.io/xivo_current.key -O - | apt-key add -
RUN apt-get -qq update && apt-get -qq -y install \
    dahdi-linux-dev \
    freetds-dev \
    libasound2-dev \
    libbluetooth-dev \
    libc-client-dev \
    libcap-dev \
    libcurl4-openssl-dev \
    libgsm1-dev \
    libical-dev \
    libiksemel-dev \
    libjansson-dev \
    liblua5.1-dev \
    libneon27-dev \
    libnewt-dev \
    libogg-dev \
    libopenr2-dev \
    libpjproject-dev \
    libpopt-dev \
    libpq-dev \
    libpri-dev \
    libfreeradius-client-dev \
    libreadline-dev \
    libresample1-dev \
    libsnmp-dev \
    libspandsp-dev \
    libspeex-dev \
    libspeexdsp-dev \
    libsqlite-dev \
    libsqlite3-dev \
    libsrtp0-dev \
    libss7-dev \
    libssl-dev \
    libtonezone-dev \
    liburiparser-dev \
    libvorbis-dev \
    libxml2-dev \
    libxslt1-dev \
    portaudio19-dev \
    postgresql-server-dev-all \
    python \
    python-pip \
    quilt \
    unixodbc-dev \
    uuid-dev \
    zlib1g-dev

# Install Asterisk
WORKDIR /usr/src
RUN wget -nv -T10 -t3 http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-$ASTERISK_VERSION.tar.gz
RUN tar xf asterisk-$ASTERISK_VERSION.tar.gz
WORKDIR /usr/src/asterisk-$ASTERISK_VERSION
COPY debian/patches /usr/src/asterisk-$ASTERISK_VERSION/patches/
RUN quilt push -a
RUN ./configure --without-h323 --without-misdn
RUN make
RUN make install

# Install XiVO confgend client
WORKDIR /usr/src
RUN git clone --depth 1 https://github.com/xivo-pbx/xivo-confgend-client.git
WORKDIR /usr/src/xivo-confgend-client/
RUN apt-get -y -qq install python-dev
RUN pip install -r requirements.txt
RUN python setup.py install

# Install Chan SCCP
WORKDIR /usr/src
RUN git clone --depth 1 https://github.com/xivo-pbx/xivo-libsccp.git
WORKDIR /usr/src/xivo-libsccp
RUN make
RUN make install

# Install base config
WORKDIR /usr/src
RUN git clone --depth 1 https://github.com/xivo-pbx/xivo-config.git
WORKDIR /usr/src/xivo-config
RUN mkdir -p /usr/share/xivo-config/dialplan/
RUN cp -a dialplan/asterisk /usr/share/xivo-config/dialplan/
RUN cp -a etc/asterisk /etc
RUN mkdir /etc/xivo
RUN cp -a etc/xivo/asterisk /etc/xivo/
RUN ln -s /var/lib/asterisk /usr/share/asterisk
RUN mkdir /etc/odbc/
RUN mv /etc/odbc*.ini /etc/odbc
RUN ln -s /etc/odbc/odbc.ini /etc/
RUN ln -s /etc/odbc/odbcinst.ini /etc/
WORKDIR /root

# Clean
RUN rm -rf /usr/src/*

EXPOSE 2000 5038 5060/udp

CMD ["asterisk", "-dvf"]
