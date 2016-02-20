FROM ubuntu:trusty

ENV TZ America/Los_Angeles

# Set maintainer
MAINTAINER gwmullin <gwmullin@gmail.com>

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y dist-upgrade && \
  locale-gen en_US.UTF-8

# Install basic software.
RUN apt-get install -y git python-lxml xml-core libxslt1-dev libxslt1.1 libxml2-dev libxml2 libssl-dev libffi-dev python-pip python-dev libssl-dev build-essential
RUN pip install --upgrade pyopenssl

# Install additional software.
RUN apt-get install -y htop nmon vnstat tcptrack bwm-ng mytop

RUN mkdir -p /opt/couchpotato
WORKDIR /opt/couchpotato
RUN git clone https://github.com/CouchPotato/CouchPotatoServer.git

RUN mkdir /couchpotato

VOLUME [ "/couchpotato" ]

EXPOSE 5050

ENTRYPOINT ["/opt/couchpotato/CouchPotatoServer/CouchPotato.py"]
CMD ["--data_dir=/couchpotato", "--debug", "--console_log"]

