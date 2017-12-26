FROM debian:stretch
MAINTAINER Wazo Maintainers <dev@wazo.community>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -q update && apt-get -q -y install \
    apt-utils \
    gnupg \
    wget
RUN echo "deb http://mirror.wazo.community/debian/ wazo-dev-stretch main" > /etc/apt/sources.list.d/wazo-dist.list
RUN wget http://mirror.wazo.community/wazo_current.key -O - | apt-key add -
RUN apt-get install init-system-helpers libasound2 libc6 libcap2 libcurl3 libfreeradius3 libgcc1 libgsm1 libical2 libiksemel3 libjack-jackd2-0 libjansson4 liblua5.1-0 libneon27 libodbc1 libogg0 libopenr2-3 libpci3 libportaudio2 libpq5 libpri1.4 libresample1 libsensors4 libsnmp30 libspandsp2 libspeex1 libspeexdsp1 libsqlite0 libsqlite3-0 libsrtp0 libss7-2.0 libssl1.1 libstdc++6 libsybdb5 libtiff5 libtinfo5 libtonezone2.0 libunbound2 liburiparser1 libuuid1 libvorbis0a libvorbisenc2 libvorbisfile3 libwrap0 libxml2 libxslt1.1 zlib1g adduser mpg123
RUN apt-get -q update && apt-get -q -y install \
    asterisk \
    xivo-libsccp

EXPOSE 2000 5038 5060/udp

CMD ["asterisk", "-dvf"]
