FROM alpine:3.19.1

ARG KAFKA_VERSION=3.6.0
ARG SCALA_VERSION=2.13

ENV KAFKA_VERSION=$KAFKA_VERSION \
    SCALA_VERSION=$SCALA_VERSION \
    KAFKA_HOME=/opt/kafka

ENV PATH=${PATH}:${KAFKA_HOME}/bin

COPY kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz /tmp/
COPY start-kafka.sh /tmp/

RUN apk add openjdk11 docker bash

RUN    chmod a+x /tmp/*.sh \
    && mv /tmp/start-kafka.sh /usr/bin \
    && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
    && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
    && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME}

#COPY server.properties $KAFKA_HOME/config

VOLUME ["/kafka"]

CMD start-kafka.sh
#CMD ["ls", "/opt/kafka/kafka_2.13-2.6.0"]