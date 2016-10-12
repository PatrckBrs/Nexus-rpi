FROM resin/rpi-raspbian:wheezy

ENV DEBIAN_FRONTEND noninteractive
ENV SONATYPE_WORK /opt/sonatype-work
RUN apt-get -qq update && apt-get -qqy upgrade && apt-get -qqy install --no-install-recommends bash supervisor procps sudo ca-certificates openjdk-7-jre-headless && apt-get clean

ADD http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz /tmp/nexus.tar
RUN tar xfv /tmp/nexus.tar -C /opt && rm /tmp/nexus.tar
RUN /usr/sbin/useradd --create-home --home-dir /home/nexus --shell /bin/bash nexus
RUN ln -s `find /opt -maxdepth 1 -type d -iname "nexus-*"` /opt/nexus

RUN chown -R nexus.nexus /opt/sonatype-work `find /opt -maxdepth 1 -type d -iname "nexus-*"`

EXPOSE 8081

VOLUME  ["/opt/sonatype-work", "/opt/nexus/conf"]

WORKDIR /opt/nexus
USER nexus
ENV CONTEXT_PATH /
ENV MAX_HEAP 768m
ENV MIN_HEAP 256m
ENV JAVA_OPTS -server -XX:MaxPermSize=192m -Djava.net.preferIPv4Stack=true
ENV LAUNCHER_CONF ./conf/jetty.xml ./conf/jetty-requestlog.xml
CMD java \
  -Dnexus-work=${SONATYPE_WORK} -Dnexus-webapp-context-path=${CONTEXT_PATH} \
  -Xms${MIN_HEAP} -Xmx${MAX_HEAP} \
  -cp 'conf/:lib/*' \
  ${JAVA_OPTS} \
  org.sonatype.nexus.bootstrap.Launcher ${LAUNCHER_CONF}
