## Image to build from sources

FROM debian:latest
MAINTAINER Sylvain Boily "sboily@avencall.com"

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
ENV ASTERISK_VERSION 11.16.0

# Add dependencies
RUN apt-get -qq update
RUN apt-get -qq -y install wget
RUN echo "deb http://mirror.xivo.io/debian/ xivo-five main" > /etc/apt/sources.list.d/xivo.list
RUN wget http://mirror.xivo.io/xivo_current.key -O - | apt-key add -
RUN apt-get -qq update
RUN apt-get -qq -y install \
    git \
    python-pip \
    apt-utils \
    libncurses-dev \
    uuid-dev \
    libxml2-dev \
    libsqlite3-dev \
    build-essential \
    curl \
    liblua5.1-dev \
    lua5.1 \
    libssl-dev \
    libcurl4-gnutls-dev \
    libsrtp0-dev \
    libtiff-dev \
    libspandsp-dev \
    dahdi-linux-dev \
    doxygen \
    freetds-dev \
    graphviz \
    libasound2-dev \
    libbluetooth-dev \
    libc-client-dev \
    libcap-dev \
    libgsm1-dev \
    libical-dev \
    libiksemel-dev \
    libneon27-dev \
    libnewt-dev \
    libopenais-dev \
    libopenr2-dev \
    libpopt-dev \
    libpq-dev \
    libpri-dev \
    libradiusclient-ng-dev \
    libreadline-dev \
    libresample1-dev \
    libsnmp-dev \
    libspandsp-dev \
    libspeex-dev \
    libspeexdsp-dev \
    libsqlite-dev \
    libss7-dev \
    libtonezone-dev \
    libvorbis-dev \
    quilt \
    sox \
    unixodbc-dev \
    odbc-postgresql \
    zlib1g-dev

# Install Asterisk
WORKDIR /usr/src
ADD asterisk/tarballs/asterisk_$ASTERISK_VERSION+dfsg.orig.tar.gz /usr/src/
WORKDIR /usr/src/asterisk-$ASTERISK_VERSION
COPY asterisk/patches /usr/src/asterisk-$ASTERISK_VERSION/patches/
RUN quilt push -a
RUN ./configure --with-imap=system --without-h323 --without-misdn --enable-dev-mode
RUN make
RUN make install

# Install XiVO confgend client
WORKDIR /usr/src
RUN git clone https://github.com/xivo-pbx/xivo-confgend-client.git
WORKDIR /usr/src/xivo-confgend-client/
RUN apt-get -y -qq install python-dev
RUN pip install -r requirements.txt
RUN python setup.py install

# Install Chan SCCP
WORKDIR /usr/src
RUN git clone https://github.com/xivo-pbx/xivo-libsccp.git
WORKDIR /usr/src/xivo-libsccp/xivo-libsccp
RUN make
RUN make install

# Install base config
WORKDIR /usr/src
RUN git clone https://github.com/xivo-pbx/xivo-config.git
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

EXPOSE 5060/udp
EXPOSE 5038
EXPOSE 2000

CMD asterisk -dvf
