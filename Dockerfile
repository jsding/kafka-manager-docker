FROM debian:stretch-slim

ENV LANG C.UTF-8
ARG VERSION=2.0.0.2
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && mkdir -p /usr/share/man/man1/ \
  && apt-get install --no-install-recommends -y openjdk-8-jdk-headless unzip wget\
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir /app
RUN mkdir -p tmp src && wget -nv https://github.com/yahoo/kafka-manager/archive/$VERSION.tar.gz -O tmp/kafka-manager.tar.gz && tar -xf tmp/kafka-manager.tar.gz -C src && cd src/kafka-manager-$VERSION && echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt && ./sbt update && ./sbt dist

COPY src/kafka-manager-$VERSION/target/universal/kafka-manager-$VERSION.zip /tmp
RUN unzip -d /tmp /tmp/kafka-manager-$VERSION.zip && mv /tmp/kafka-manager-$VERSION/* /app/ \
 && rm -rf /tmp/kafka-manager* && rm -rf /app/share/doc
ADD entrypoint.sh /app/
ADD application.conf /app/conf/
ADD logback.xml /app/conf/

WORKDIR /app

EXPOSE 9000
ENTRYPOINT ["./entrypoint.sh"]
