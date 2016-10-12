FROM resin/rpi-raspbian:jessie

ENV DEBIAN_FRONTEND noninteractive

ENV NEXUS_DATA /nexus-data

RUN apt-get -qq update && \
	apt-get -qqy upgrade && \
	apt-get -qqy install --no-install-recommends \
	wget \
	gzip \
	openjdk-8-jre-headless && \
	apt-get clean
	
# install nexus
RUN mkdir -p /opt/sonatype/nexus && \
	wget https://www.sonatype.com/oss-thank-you-tar.gz -P /tmp && \
	cd /opt/sonatype/nexus && tar xzvf /tmp/oss-thank-you-tar.gz
RUN chown -R root:root /opt/sonatype/nexus

  
## configure nexus runtime env
RUN sed \
    -e "s|karaf.home=.|karaf.home=/opt/sonatype/nexus|g" \
    -e "s|karaf.base=.|karaf.base=/opt/sonatype/nexus|g" \
    -e "s|karaf.etc=etc|karaf.etc=/opt/sonatype/nexus/etc|g" \
    -e "s|java.util.logging.config.file=etc|java.util.logging.config.file=/opt/sonatype/nexus/etc|g" \
    -e "s|karaf.data=data|karaf.data=${NEXUS_DATA}|g" \
    -e "s|java.io.tmpdir=data/tmp|java.io.tmpdir=${NEXUS_DATA}/tmp|g" \
    -i /opt/sonatype/nexus/bin/nexus.vmoptions

RUN useradd -r -u 200 -m -c "nexus role account" -d ${NEXUS_DATA} -s /bin/false nexus

VOLUME ${NEXUS_DATA}

EXPOSE 8081
USER nexus
WORKDIR /opt/sonatype/nexus

ENV JAVA_MAX_MEM 512m
ENV JAVA_MIN_MEM 512m
ENV EXTRA_JAVA_OPTS ""

CMD ["bin/nexus", "run"]
