#!/bin/sh

####################################################################
#    ntp_update
#
#    Update real-time clock and log to logfile
#
#    
#    Thomas Ingeman-Nielsen - 2021-05-29
####################################################################

source "./cronscripter_settings"
source "./helper_functions.sh"

touch $LOGDIR/logfile

check_if_terrameter_runs "NTP"

if [ $running -eq 0 ]
then
    $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "NTP: Attempting clock update" >> $LOGDIR/logfile
    OUT=`ntpdate 192.168.23.1 | grep "adjust time server"`

    if [ $? -eq 0 ]
    then
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "NTP: SUCCESS: $OUT" >> $LOGDIR/logfile
    else
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "NTP: Clock update failed" >> $LOGDIR/logfile
    fi
else
    $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "NTP: Terrameter runs => Die." >> $LOGDIR/logfile
fi

