FROM debian:jessie
MAINTAINER dev+docker@proformatique.com

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -q update && apt-get -q -y install \
    apt-utils \
    wget
RUN echo "deb http://mirror.xivo.io/debian/ xivo-dev main" > /etc/apt/sources.list.d/xivo.list
RUN wget http://mirror.xivo.io/xivo_current.key -O - | apt-key add -
RUN apt-get -q update && apt-get -q -y install \
    asterisk \
    xivo-libsccp

EXPOSE 2000 5038 5060/udp

CMD ["asterisk", "-dvf"]
