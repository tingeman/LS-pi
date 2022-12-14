#!/bin/sh

# Use as 
#
#	set_pending_reboot.sh
#
#	Will create a flag file used to indicate that a reboot
#	should be performed by GO after completion of next job.
#
#	pj	2011-09-08


# This is the main program

if [[ -z $SCRIPTS_DIR ]]; then
    SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

source "$SCRIPTS_DIR/cronscripter_settings"


if [ -e $RUNFILEDIR/runfile ]
then
    $BIN/echo -n "set_pending_reboot.sh: Setting flag for reboot. " >> $LOGDIR/logfile
    $BIN/date >>$LOGDIR/logfile
    $BIN/touch $RUNFILEDIR/rebootmenow
fi
