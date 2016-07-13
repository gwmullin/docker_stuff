#!/bin/bash

echo "Running apache as ${APACHE_RUN_USER}"
echo "Running scripts as ${LOCAL_USER}"

if [[ "${RUN_CHOWN}" == "true" ]]; then
  echo "Running chown since RUN_CHOWN == true. Grab coffee, this may take a while."
  echo ""
  echo "$(date): chown/chmod on /volumes/nzbfiles starting"
  chown -R ${LOCAL_USER}:${APACHE_RUN_GROUP} /volumes/nzbfiles
  chmod -R 755 /volumes/nzbfiles
  echo "$(date): chown/chmod on /volumes/nzbfiles finished"

  echo "$(date): chown/chmod on /volumes/covers starting"
  chown -R ${LOCAL_USER}:${APACHE_RUN_GROUP} /volumes/covers && \
  chmod -R 755 /volumes/covers
  echo "$(date): chown/chmod on /volumes/covers finished"
  echo ""
  echo "Done chowning! Let's start the show."

fi
echo "Running update for DB schema. This may take a while."
php /var/www/nZEDb/zed update db


rm -f /var/run/apache2.pid
rm -f /var/run/apache2/apache2.pid

/usr/sbin/apache2 -k start &
APACHE_PID=$!

trap "{ kill $APACHE_PID ; echo 'Killed apache'; pkill -f php ; echo 'Killed php' ; sleep 10; kill $SCREEN_PID ; echo 'Killed screen' ; sleep 30; }"  SIGTERM EXIT

/usr/bin/sudo -u ${LOCAL_USER} /tmp/nzedb_threaded_updater.sh

