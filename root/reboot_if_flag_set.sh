#!/bin/sh

# Use as 
#
#	reboot_if_flag_set.sh
#
#	Will check if the flag file used to indicate that a reboot
#	should be performed by GO is present. If so, it is assumed
#	that the reboot was not performed, and an unconditional reboot
#	is performed.
#
#	pj	2011-09-08


# This is the main program

source "./cronscripter_settings"

if [ -e $RUNFILEDIR/runfile ]
then
    if [ -e $RUNFILEDIR/rebootmenow ]
    then
        $BIN/echo -n "reboot_if_flag_set.sh: Pending reboot. Force shutdown at " >> $LOGDIR/logfile
        $BIN/date >>$LOGDIR/logfile
        $BIN/rm $RUNFILEDIR/rebootmenow
        $BIN/sleep 2
        $HOME/reboot_now.sh
    fi
fi
