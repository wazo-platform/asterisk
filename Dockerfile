FROM debian:bullseye
LABEL maintainer="Wazo Maintainers <dev@wazo.community>"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -q update && apt-get -q -y install \
    apt-utils \
    gnupg \
    wget
RUN echo "deb http://mirror.wazo.community/debian/ wazo-dev-bullseye main" > /etc/apt/sources.list.d/wazo-dist.list
RUN wget http://mirror.wazo.community/wazo_current.key -O - | apt-key add -
RUN apt-get -q update && apt-get -q -y install \
    asterisk \
    wazo-libsccp \
    wazo-res-stasis-amqp

EXPOSE 2000 5038 5060/udp

CMD ["asterisk", "-dvf"]
