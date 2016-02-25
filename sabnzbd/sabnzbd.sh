#!/bin/bash
set -e

#
# Display settings on standard out.
#

USER="root"

echo "SABnzbd settings"
echo "================"
echo
echo "  User:       ${USER}"
echo
echo "  Config:     ${CONFIG:=/datadir/config.ini}"
echo "  Version:    ${VERSION:=master}"
echo

#
# Update SABnzbd and checkout requested version.
#

printf "Updating SABnzbd git repository... "
git pull -q
echo "[DONE]"

printf "Getting current version... "
CURRENT_VERSION=$(git rev-parse --abbrev-ref HEAD)
echo "[${CURRENT_VERSION}]"

if [[ "${CURRENT_VERSION}" != "${VERSION}" ]]
then
    printf "Checking out SABnzbd version '${VERSION}'... "
    git checkout -q ${VERSION}
    echo "[DONE]"
fi

#
# Because SABnzbd runs in a container we've to make sure we've a proper
# listener on 0.0.0.0. We also have to deal with the port which by default is
# 8080 but can be changed by the user.
#

printf "Get listener port... "
PORT=$(sed -n '/^port *=/{s/port *= *//p;q}' ${CONFIG})
LISTENER="-s 0.0.0.0:${PORT:=8080}"
echo "[${PORT}]"

#
# Finally, start SABnzbd.
#

echo "Starting SABnzbd..."
./SABnzbd.py -b 0 -f ${CONFIG} ${LISTENER}
