FROM ubuntu:trusty

# Set maintainer
MAINTAINER gwmullin <gwmullin@gmail.com>

# Set correct environment variables.
# Any of these vars should trigger an image rebuild
ENV TZ="America/Los_Angeles" HOME="/root" LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8" \
    LOCAL_USER="${NZEDB_USER:-www-data}" TERM="dumb"

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y dist-upgrade && \
  locale-gen en_US.UTF-8

# Install basic software.
RUN apt-get install -y curl git htop man software-properties-common unzip \
    vim wget ntp ntpdate time htop nmon vnstat tcptrack bwm-ng mytop \
    libzen0 lame p7zip-full libav-tools sudo

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
RUN apt-get install -y php5 php5-cli php5-dev php-pear php5-gd php5-mysqlnd php5-curl php5-json && \
    sed -ri 's/(max_execution_time =) ([0-9]+)/\1 120/' /etc/php5/cli/php.ini && \
    sed -ri 's/(memory_limit =) ([0-9]+)/\1 -1/' /etc/php5/cli/php.ini && \
    sed -ri 's/;(date.timezone =)/\1 America\/Los_Angeles/' /etc/php5/cli/php.ini && \
    sed -ri 's/(max_execution_time =) ([0-9]+)/\1 120/' /etc/php5/apache2/php.ini && \
    sed -ri 's/(memory_limit =) ([0-9]+)/\1 1024/' /etc/php5/apache2/php.ini && \
    sed -ri 's/;(date.timezone =)/\1 America\/Los_Angeles/' /etc/php5/apache2/php.ini && \
    sed -ri 's/(display_errors =) (.*)/\1 on/' /etc/php5/apache2/php.ini && \
    sed -ri 's/(display_errors =) (.*)/\1 on/' /etc/php5/cli/php.ini

# Install everything needed to run the website.
RUN apt-get install -y memcached php5-memcached apache2

ADD nZEDb.conf /etc/apache2/sites-available/
RUN a2dissite 000-default && \
    a2ensite nZEDb.conf && \
    a2enmod rewrite

ENV APACHE_RUN_USER="${APACHE_USER:-www-data}" \
    APACHE_RUN_GROUP="${APACHE_GROUP:-www-data}" \
    APACHE_LOG_DIR="/var/log/apache2" APACHE_LOCK_DIR="/var/lock/apache2" \
    APACHE_PID_FILE="/var/run/apache2.pid"

# Adjust php5 runtime directory
RUN chmod -R 755 /var/lib/php5

# Clone nZEDb master and set directory permissions
RUN mkdir -p /var/www
WORKDIR /var/www

RUN git clone https://github.com/nZEDb/nZEDb.git
RUN chown -R ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} nZEDb
RUN chmod 755 /var/www/nZEDb/libs/smarty/templates_c
RUN chmod 755 nZEDb
RUN chmod -R 755 /var/www/nZEDb/resources/covers
RUN chmod 755 /var/www/nZEDb/www
RUN chmod 755 /var/www/nZEDb/www/install
RUN chmod -R 755 /var/www/nZEDb/nzedb/config/

RUN mkdir -p /volumes/nzbfiles && \
    chown -R ${LOCAL_USER}:${APACHE_RUN_GROUP} /volumes/nzbfiles && \
    chmod -R 755 /volumes/nzbfiles

RUN mkdir -p /volumes/covers && \
    chown -R ${LOCAL_USER}:${APACHE_RUN_GROUP} /volumes/covers && \
    chmod -R 755 /volumes/covers

# Optional - sets debug logging
ADD settings.php settings.php
RUN chmod 755 settings.php && \
    cp settings.php /var/www/nZEDb/nzedb/config/

# Uncomment if you're configured already and have a config file to copy.
ADD config.php config.php
RUN chown ${LOCAL_USER} config.php && chmod 755 config.php && \
    mv config.php /var/www/nZEDb/nzedb/config/config.php && \
    touch /var/www/nZEDb/www/install/install.lock


# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD nzedb_threaded_updater.sh /tmp/nzedb_threaded_updater.sh
RUN chmod a+x /tmp/nzedb_threaded_updater.sh

ADD entry.sh /tmp/entry.sh
RUN chmod a+x /tmp/entry.sh

# Define mountable directories
VOLUME ["/var/www"]
VOLUME ["/volumes/nzbfiles"]
VOLUME ["/volumes/covers"]

# Expose ports
EXPOSE 8800


ENTRYPOINT /tmp/entry.sh

