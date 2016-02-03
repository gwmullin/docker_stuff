#!/bin/bash

rm -f /var/run/apache2.pid
rm -f /var/run/apache2/apache2.pid

/usr/sbin/apache2 -k start &
APACHE_PID=$!

trap "{ kill $APACHE_PID ; echo 'Killed apache'; pkill -f php ; echo 'Killed php' ; sleep 10; kill $SCREEN_PID ; echo 'Killed screen' ; sleep 30; }"  SIGTERM EXIT

cd /var/www/nZEDb/misc/update/nix/screen/sequential

while :
do
	./threaded.sh
	sleep 60
done
