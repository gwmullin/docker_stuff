FROM ubuntu:trusty

# Set maintainer
MAINTAINER gwmullin <gwmullin@gmail.com>

# Set correct environment variables.
ENV TZ America/Los_Angeles
ENV HOME /root
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LOCAL_USER ${NZEDB_USER:-www-data}

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y dist-upgrade && \
  locale-gen en_US.UTF-8

# Install basic software.
RUN apt-get install -y curl git htop man software-properties-common unzip vim wget ntp ntpdate time

# Install additional software.
RUN apt-get install -y htop nmon vnstat tcptrack bwm-ng mytop libzen0 lame p7zip-full libav-tools

# Install Python MySQL modules.
RUN \
  apt-get install -y python-setuptools software-properties-common python3-setuptools python3-pip python-pip && \
  python -m easy_install pip && \
  easy_install cymysql && \
  easy_install pynntp && \
  easy_install socketpool && \
  pip list && \
  python3 -m easy_install pip && \
  pip3 install cymysql && \
  pip3 install pynntp && \
  pip3 install socketpool && \
  pip3 list && \
  apt-get update && \
  apt-get install -y -f tmux && \
  apt-get install -y screen

# Install PHP.
RUN apt-get install -y php5 php5-cli php5-dev php-pear php5-gd php5-mysqlnd php5-curl php5-json
RUN sed -ri 's/(max_execution_time =) ([0-9]+)/\1 120/' /etc/php5/cli/php.ini
RUN sed -ri 's/(memory_limit =) ([0-9]+)/\1 -1/' /etc/php5/cli/php.ini
RUN sed -ri 's/;(date.timezone =)/\1 America\/Los_Angeles/' /etc/php5/cli/php.ini
RUN sed -ri 's/(max_execution_time =) ([0-9]+)/\1 120/' /etc/php5/apache2/php.ini
RUN sed -ri 's/(memory_limit =) ([0-9]+)/\1 1024/' /etc/php5/apache2/php.ini
RUN sed -ri 's/;(date.timezone =)/\1 America\/Los_Angeles/' /etc/php5/apache2/php.ini
RUN sed -ri 's/(display_errors =) (.*)/\1 on/' /etc/php5/apache2/php.ini
RUN sed -ri 's/(display_errors =) (.*)/\1 on/' /etc/php5/cli/php.ini

# Install memcached.
RUN apt-get install -y memcached php5-memcached

RUN apt-get install -y apache2
RUN apt-get install -y inetutils-telnet
ADD nZEDb.conf /etc/apache2/sites-available/
RUN a2dissite 000-default && \
    a2ensite nZEDb.conf && \
    a2enmod rewrite

# Clone nZEDb master and set directory permissions
RUN mkdir -p /var/www
WORKDIR /var/www
RUN git clone https://github.com/nZEDb/nZEDb.git
RUN chown -R www-data:www-data nZEDb/www
RUN chmod 777 /var/www/nZEDb/libs/smarty/templates_c
RUN chmod 777 nZEDb
RUN chmod -R 777 /var/www/nZEDb/resources/covers
RUN chmod 777 /var/www/nZEDb/www
RUN chmod 777 /var/www/nZEDb/www/install
RUN mkdir -p /volumes/nzbfiles
RUN chown -R www-data:www-data /volumes/nzbfiles
RUN mkdir -p /volumes/covers
RUN chown -R www-data:www-data /volumes/covers
RUN chmod -R 777 /var/www/nZEDb/nzedb/config/


ADD entry.sh /root/entry.sh
RUN chmod a+x /root/entry.sh

# Optional - sets debug logging
ADD settings.php /root/settings.php
RUN chmod 777 /root/settings.php && \
    cp /root/settings.php /var/www/nZEDb/nzedb/config/

# Uncomment if you're configured already and have a config file to copy.
ADD config.php /root/config.php
RUN chmod 777 /root/config.php && \
    mv /root/config.php /var/www/nZEDb/nzedb/config/config.php && \
    touch /var/www/nZEDb/www/install/install.lock


# Adjust php5 runtime directory
RUN chmod -R 777 /var/lib/php5

# Define mountable directories
VOLUME ["/var/www"]
#VOLUME ["/volumes/nzbfiles"]
#VOLUME ["/volumes/covers"]

# Expose ports
EXPOSE 8800

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV TERM dumb

ENTRYPOINT /root/entry.sh

