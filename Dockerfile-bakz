FROM resin/rpi-raspbian:jessie

ENV DEBIAN_FRONTEND noninteractive
ENV SONATYPE_WORK /opt/sonatype-work
RUN apt-get -qq update && \
    apt-get -qqy upgrade && \
    apt-get -qqy install --no-install-recommends \
    bash \
    supervisor \
    procps \
    sudo \
    wget \
    ca-certificates \
    openjdk-7-jre-headless \
    openjdk-8-jre-headless && \
    apt-get clean

RUN wget https://sonatype-download.global.ssl.fastly.net/nexus/3/nexus-3.0.2-02-unix.tar.gz -O /tmp/nexus-3.0.2-02-unix.tar.gz && \
        useradd -r -u 200 -m -c "nexus role account" -d /opt/sonatype-work -s /bin/false nexus && \
        mkdir -p /opt/sonatype/ && \
        mkdir -p /opt/sonatype-work && \
        tar -C /opt/sonatype/ -xvaf /tmp/nexus-3.0.2-02-unix.tar.gz && \
        ln -s /opt/sonatype/nexus-3.0.2-02/ /opt/sonatype/nexus && \
        rm -f /tmp/nexus-3.0.2-02-unix.tar.gz && \
        chown -Rv nexus:nexus /opt/sonatype/nexus && \
        chown -Rv nexus:nexus /opt/sonatype/nexus-3.0.2-02 && \
        chown -Rv nexus:nexus /opt/sonatype-work

VOLUME /opt/sonatype-work

WORKDIR /opt/sonatype/nexus

COPY nexus.vmoptions /opt/sonatype/nexus/bin/nexus.vmoptions

EXPOSE 8081

USER nexus
CMD ["/opt/sonatype/nexus/bin/nexus", "run"]
