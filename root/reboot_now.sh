#!/bin/bash

source "./cronscripter_settings"

touch $LOGDIR/logfile
$BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "=== INITIATING FORCED REBOOT ==========================" >> $LOGDIR/logfile 
sleep 2
/sbin/reboot



