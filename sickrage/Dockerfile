FROM ubuntu:trusty

# Set maintainer
MAINTAINER gwmullin <gwmullin@gmail.com>

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y dist-upgrade && \
  locale-gen en_US.UTF-8

# Install basic software.
RUN apt-get install -y libxslt1-dev libxslt1.1 libxml2-dev libxml2 libssl-dev libffi-dev python-pip python-dev libssl-dev git build-essential unrar
RUN sudo pip install pyopenssl

# Install additional software.
RUN apt-get install -y htop nmon vnstat tcptrack bwm-ng mytop

RUN mkdir -p /opt/sickrage
WORKDIR /opt/sickrage
RUN git clone https://github.com/SickRage/SickRage.git

RUN mkdir /sickrage && \
    mkdir /sickrage/config


VOLUME [ "/sickrage" ]

EXPOSE 8080

ENTRYPOINT ["/opt/sickrage/SickRage/SickBeard.py"]
CMD ["--datadir=/sickrage/config", "--port=8080"]

