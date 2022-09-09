#!/bin/bash

if [[ -z $SCRIPTS_DIR ]]; then
    SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

source "$SCRIPTS_DIR/cronscripter_settings"


touch $LOGDIR/logfile
$BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "=== INITIATING FORCED REBOOT ==========================" >> $LOGDIR/logfile 
sleep 2
/sbin/reboot



