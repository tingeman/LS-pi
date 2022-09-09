#!/bin/bash

####################################################################
#        SIGNALCOMPLETE
# 
#        Create a file on the IOT-GATE-iMX7 signalling that 
#        measurements completed.
#        The file is called MEASURECOMPLETE and contains the
#        date/time of completion.
#        Created by ssh commands to the IOT.
#
#        Thomas Ingeman-Nielsen - 2021-09-03
####################################################################


start_upload()
{
    
    $SSH "touch $IOTDATADIR/MEASURECOMPLETE && echo `date` > $IOTDATADIR/MEASURECOMPLETE"
         
    if [ $? -eq 0 ]
    then
         sig_ok=1
         $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "COMPLETE: Signal sent" >> $LOGDIR/logfile
    else
        sig_ok=0
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"`  "COMPLETE: Signal failed." >> $LOGDIR/logfile   
    fi
}

# This is the main program

if [[ -z $SCRIPTS_DIR ]]; then
    SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

source "$SCRIPTS_DIR/cronscripter_settings"
source "$SCRIPTS_DIR/helper_functions.sh"

$BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "COMPLETE: Signaling to IOT that measurements completed" >> $LOGDIR/logfile

ssh_ok=1
test_ssh_connectivity "COMPLETE"

if [ $ssh_ok -eq 1 ]
then
    start_upload
else
    $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "COMPLETE: Could not connect." >> $LOGDIR/logfile
    #$BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "UPL: Could not connect, set pending reboot!" >> $LOGDIR/logfile
    #$HOME/set_pending_reboot.sh
fi

