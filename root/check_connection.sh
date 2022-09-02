#!/bin/bash

####################################################################
#        check_connection will test ssh connection
#        and schedule a reboot by setting the rebootmenow file
#        in the runfile directory if connection cannot be
#        established. This will trigger a reboot after the end
#        of the next scheduled GO script execution.
#
#
#        Thomas Ingeman-Nielsen - 2021-06-07
####################################################################


test_connectivity()
{
    ssh_ok=0

    $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "CHK: Trying $SSH" >> $LOGDIR/uploadlog
    HOST=`$SSH hostname 2>> $LOGDIR/uploadlog`

    if [ $? -eq 0 ]
    then
        ssh_ok=1
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "CHK: Connected OK to $HOST" >> $LOGDIR/uploadlog
    else
        ssh_ok=0
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "CHK: Failed to connect" >> $LOGDIR/uploadlog
    fi
}


# This is the main program

source "./cronscripter_settings"

$BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "CHK: Testing SSH connection..." >> $LOGDIR/uploadlog

test_connectivity

if [ $ssh_ok -eq 1 ]
then
    $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "CHK: All good, exiting." >> $LOGDIR/uploadlog
else
    $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "CHK: Could not connect, setting reboot flag" >> $LOGDIR/uploadlog
    /home/root/set_pending_reboot.sh    
fi







