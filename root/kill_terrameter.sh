#!/bin/bash

source "./cronscripter_settings"

if [ -e $RUNFILEDIR/runfile ]
then
    /usr/bin/killall terrameter
    $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "Killall terrameter" >> $LOGDIR/logfile
else
    $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"`  "Runfile not present, aborting kill" >> $LOGDIR/logfile
fi

