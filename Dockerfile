FROM resin/rpi-raspbian:jessie

ENV DEBIAN_FRONTEND noninteractive

ENV NEXUS_DATA /nexus-data
ENV NEXUS_VERSION latest-bundle

RUN apt-get update && \
	apt-get -y upgrade && \
	apt-get -y install --no-install-recommends \
	curl \
	wget \
	openjdk-8-jre-headless && \
	apt-get clean
	
# install nexus
RUN mkdir -p /opt/sonatype/nexus && \
	curl --fail --silent --location --retry 3 https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}.tar.gz \
  | gunzip \
  | tar x -C /opt/sonatype/nexus --strip-components=1 nexus-${NEXUS_VERSION} && \
  chown -R root:root /opt/sonatype/nexus 
  
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
