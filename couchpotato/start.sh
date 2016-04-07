#!/bin/bash

cd /opt/couchpotato

# Check if we are in a git repo
git rev-parse --git-dir > /dev/null 2>&1

if [ $? -gt 0 ]; then
	git clone https://github.com/CouchPotato/CouchPotatoServer.git
else
	git pull
fi

while [ /bin/true ]; do
	echo "Starting Couchpotato"
	sleep 2  # allows for restarts from ui
	/opt/couchpotato/CouchPotatoServer/CouchPotato.py --data_dir=/couchpotato --debug --console_log
done
