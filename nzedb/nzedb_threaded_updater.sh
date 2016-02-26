#!/bin/bash

cd /var/www/nZEDb/misc/update/nix/screen/threaded

if [ -e "nZEDbBase.php" ]
then
        export NZEDB_ROOT="$(pwd)"
else
        export NZEDB_ROOT="$(php ../../../../../nZEDbBase.php)"
fi

export NZEDB_PATH="${NZEDB_ROOT}/misc/update"
export HELP_PATH="${NZEDB_ROOT}/misc/update/nix/screen/threaded"
export THREAD_PATH="${NZEDB_ROOT}/misc/update/nix/multiprocessing"
export TEST_PATH="${NZEDB_ROOT}/misc/testing"

command -v php5 >/dev/null 2>&1 && export PHP=`command -v php5` || { export PHP=`command -v php`; }
command -v python3 >/dev/null 2>&1 && export PYTHON=`command -v python3` || { export PYTHON=`command -v python`; }

export NZEDB_SLEEP_TIME="60"
           LASTOPTIMIZE=`date +%s`
           LASTOPTIMIZE1=`date +%s`
           LASTOPTIMIZE2=`date +%s`

while :
do
        sleep 1
        CURRTIME=`date +%s`
        #tmux kill-session -t NNTPProxy
        #$PHP ${NZEDB_PATH}/nntpproxy.php

        cd ${NZEDB_PATH}
	pgrep -f postprocess.php > /dev/null 2>&1
	if [ $? -gt 0 ] ; then
		echo "Kicking off persistent postprocess"
                cd $NZEDB_PATH && $PHP $NZEDB_PATH/postprocess.php allinf true &
        fi

        cd ${THREAD_PATH}
                echo "Start Multi-Processing binaries.php..."
        $PHP ${THREAD_PATH}/binaries.php 0
                echo "Start Multi-Processing backfill.php..."
        $PHP ${THREAD_PATH}/backfill.php

        cd ${HELP_PATH}
	pgrep -f helper.sh > /dev/null 2>&1
        if [ $? -gt 0 ]; then
                echo "Kicking off persistent helper"
                cd $HELP_PATH && $HELP_PATH/helper.sh &
        fi

        cd ${TEST_PATH}
        DIFF=$(($CURRTIME-$LASTOPTIMIZE))
        if [ "$DIFF" -gt 900 ] || [ "$DIFF" -lt 1 ]
        then
                LASTOPTIMIZE=`date +%s`
                echo "Cleaning DB..."
                $PHP ${TEST_PATH}/Release/fixReleaseNames.php 1 true all yes
                $PHP ${TEST_PATH}/Release/fixReleaseNames.php 3 true other yes
                $PHP ${TEST_PATH}/Release/fixReleaseNames.php 5 true other yes
        fi

        cd ${NZEDB_PATH}
        DIFF=$(($CURRTIME-$LASTOPTIMIZE1))
        if [ "$DIFF" -gt 14400 ] || [ "$DIFF" -lt 1 ]
        then
                LASTOPTIMIZE1=`date +%s`
                echo "Optimizing DB..."
                $PHP ${NZEDB_PATH}/optimise_db.php space
        fi

        DIFF=$(($CURRTIME-$LASTOPTIMIZE2))
        if [ "$DIFF" -gt 43200 ] || [ "$DIFF" -lt 1 ]
        then
                LASTOPTIMIZE2=`date +%s`
                echo "Updating schedules..."
                #$PHP ${NZEDB_PATH}/update_tvschedule.php
                $PHP ${NZEDB_PATH}/update_theaters.php
        fi

        echo "waiting ${NZEDB_SLEEP_TIME} seconds..."
        sleep ${NZEDB_SLEEP_TIME}

done
