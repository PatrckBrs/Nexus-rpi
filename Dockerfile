FROM resin/rpi-raspbian:jessie

ENV DEBIAN_FRONTEND noninteractive
ENV SONATYPE_WORK /opt/sonatype-work

RUN apt-get update && \
	apt-get -y upgrade && \
	apt-get -y install --no-install-recommends \
	wget \
	openjdk-8-jre-headless && \
	apt-get clean

RUN mkdir -p /opt/sonatype/nexus && mkdir -p /opt/sonatype-work && \ 
	wget http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz -P /tmp/

RUN tar xzvf /tmp/nexus*.tar.gz -C /opt/sonatype/nexus && rm /tmp/nexus*.tar.gz

RUN /usr/sbin/useradd --create-home --home-dir /home/nexus --shell /bin/bash nexus

EXPOSE 8081

VOLUME  ["/opt/sonatype-work"]

WORKDIR /opt/sonatype/nexus
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
