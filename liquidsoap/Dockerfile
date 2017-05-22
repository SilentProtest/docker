FROM armhf/ubuntu
MAINTAINER SilentProtest

RUN groupadd -r liquidsoap \
    && useradd -r -g liquidsoap liquidsoap

RUN set -x \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends liquidsoap liquidsoap-plugin-all \
    &&  rm -rf /var/lib/apt/lists/* 

USER liquidsoap

EXPOSE 8005

CMD ["liquidsoap", "/radio.liq"]
