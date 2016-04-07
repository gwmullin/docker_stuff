FROM ubuntu:trusty

ENV TZ America/Los_Angeles
ENV LOCAL_USER ${COUCHPOTATO_USER:-root}

# Set maintainer
MAINTAINER gwmullin <gwmullin@gmail.com>

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y dist-upgrade && \
  locale-gen en_US.UTF-8

# Install basic software.
RUN apt-get install -y git python-lxml xml-core libxslt1-dev libxslt1.1 libxml2-dev libxml2 libssl-dev libffi-dev python-pip python-dev libssl-dev build-essential p7zip unrar
RUN pip install --upgrade pyopenssl

# Install additional software.
RUN apt-get install -y htop nmon vnstat tcptrack bwm-ng mytop

RUN mkdir /couchpotato && chown ${LOCAL_USER} /couchpotato
RUN mkdir -p /opt/couchpotato && chown ${LOCAL_USER} /opt/couchpotato

USER ${LOCAL_USER}

RUN chown ${LOCAL_USER} /opt/couchpotato

#
# Add Couchpotato init script.
#

ADD start.sh /start.sh
RUN chmod 755 /start.sh


VOLUME [ "/couchpotato" ]
VOLUME [ "/opt/couchpotato" ]

EXPOSE 5050

CMD ["/start.sh"]

