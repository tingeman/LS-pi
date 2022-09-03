check_if_terrameter_runs()
{
    CALLER=${1:-"???"}

    A=`$BIN/ps -C terrameter | $BIN/grep -v PID`
    #A=`$BIN/ps -e | $USRBIN/pgrep terrameter`
    if [ "$A" ]
    then
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: Terrameter software is running" >> $LOGDIR/logfile
        running=1
    else
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: Terrameter software is not running, continue." >> $LOGDIR/logfile
        running=0
        #$BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: DEBUG: ps -A" >> $LOGDIR/logfile
        #$BIN/ps -A >> $LOGDIR/logfile
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: DEBUG: ps -e | pgrep terrameter" >> $LOGDIR/logfile
        $BIN/ps -e | $USRBIN/pgrep terrameter >> $LOGDIR/logfile
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: DEBUG: ps -C terrameter| grep -v PID" >> $LOGDIR/logfile
        $BIN/ps -C terrameter | $BIN/grep -v PID >> $LOGDIR/logfile
    fi
}


start_job()
{
    CALLER=${1:-"???"}
    
    if [ -e $CFile ]
    then
        $BIN/echo " " >> $WORKDIR/ttyfile
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: Start processing commandfile $CFile" >> $WORKDIR/ttyfile
        $BIN/echo " " >> $WORKDIR/ttyfile
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: Start processing commandfile $CFile" >> $LOGDIR/logfile
        $BIN/bash $HOME/cronscripter $CFile | "$TERRAMETER_CMD" 1>> $WORKDIR/ttyfile 2>> $WORKDIR/errfile
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: Done processing commandfile $CFile" >> $LOGDIR/logfile
    else
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: No commandfile ($CFile)" >> $LOGDIR/logfile
    fi
}


check_if_rsync_runs()
{
    CALLER=${1:-"???"}
    
    A=`$BIN/ps -C rsync | $BIN/grep -v PID`
    if [ "$A" ]
    then
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: rsync is running" >> $LOGDIR/logfile
        sync=1
    else
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: rsync is not running, continue." >> $LOGDIR/logfile
        sync=0
    fi
}


test_ssh_connectivity()
{
    CALLER=${1:-"???"}

    ssh_ok=0

    $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: Trying $SSH" >> $LOGDIR/logfile
    THISPARTICULARHOST=`$SSH hostname`

    if [ $? -eq 0 ]
    then
        ssh_ok=1
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: Connected OK to $THISPARTICULARHOST" >> $LOGDIR/logfile
    else
        ssh_ok=0
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: Failed to connect" >> $LOGDIR/logfile
    fi
}


kill_terrameter()
{
    CALLER=${1:-"???"}

    $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: Attempting to kill Terrameter." >> $LOGDIR/logfil
    $USRBIN/killall terrameter
    
    $BIN/sleep 15
}


kill_rsync()
{
    CALLER=${1:-"???"}

    $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$CALLER: Attempting to kill rsync." >> $LOGDIR/logfile
    $USRBIN/killall upload.sh
    $USRBIN/killall rsync

    $BIN/sleep 15
}

