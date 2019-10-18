FROM debian:stretch-slim

ENV LANG C.UTF-8
ARG VERSION=2.0.0.2
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && mkdir -p /usr/share/man/man1/ \
  && apt-get install --no-install-recommends -y openjdk-8-jdk-headless unzip wget\
  && apt-get clean && rm -rf /var/lib/apt/lists/*



RUN mkdir /app
RUN mkdir -p /tmp /src 
RUN wget -nv https://github.com/yahoo/kafka-manager/archive/2.0.0.2.tar.gz -O /tmp/kafka-manager.tar.gz 
RUN tar -xf /tmp/kafka-manager.tar.gz -C /src
RUN cd /src/kafka-manager-2.0.0.2 && ./sbt update && ./sbt clean dist

RUN cp /src/kafka-manager-2.0.0.2/target/universal/kafka-manager-2.0.0.2.zip /tmp
RUN unzip -d /tmp /tmp/kafka-manager-2.0.0.2.zip && mv /tmp/kafka-manager-2.0.0.2/* /app/ \
  && rm -rf /tmp/kafka-manager* && rm -rf /app/share/doc

ADD entrypoint.sh /app/
ADD application.conf /app/conf/
ADD logback.xml /app/conf/

WORKDIR /app

EXPOSE 9000
ENTRYPOINT ["./entrypoint.sh"]
