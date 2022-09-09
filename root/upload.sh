#!/bin/bash

####################################################################
#        UPLOAD to NAS drive
#
#
#        Joseph Doetsch - 2013-05-04
####################################################################

# rsync arguments
# 
# -a, --archive               archive mode; equals -rlptgoD (no -H,-A,-X)
# -r, --recursive             recurse into directories
# -l, --links                 copy symlinks as symlinks
# -p, --perms                 preserve permissions
# -t, --times                 preserve modification times
# -g, --group                 preserve group
# -o, --owner                 preserve owner (super-user only)
# -D                          same as --devices --specials
#     --devices               preserve device files (super-user only)
#     --specials              preserve special files
#     --timeout=SECONDS       set I/O timeout in seconds
# -e, --rsh=COMMAND           specify the remote shell to use
#     --exclude=PATTERN       exclude files matching PATTERN


start_usbcopy()
{
    if [ -d $UPLSOURCEDIR ]
    then
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "UPL: Start copy to USB" >> $LOGDIR/logfile
        $USRBIN/rsync -rtlDz --timeout=300 --chmod "Da=rw,Fa=rw" $UPLSOURCEDIR $USBDESTDIR 2>> $LOGDIR/logfile
             
        if [ $? -eq 0 ]
        then
             upl_ok=1
             $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "UPL: copy done" >> $LOGDIR/logfile
             let delay_days=$RMRAWDELAY/1440
             $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "UPL: Delete raw data older than $delay_days day(s)." >> $LOGDIR/logfile
             $USRBIN/find $UPLSOURCEDIR/*/RawData/* -mmin +$RMRAWDELAY -exec rm {} \;
             # find and remove any files older than RMRAWDELAY minutes located in RawData folders 
             
             # then remove any empty subfolders starting with 00 and the RawData folders themselves
             # will only delete empty folders.
             rmdir $UPLSOURCEDIR/*/Rawdata/00*
             rmdir $UPLSOURCEDIR/*/Rawdata
             
             #$BIN/echo -n "DEBUGGING: Files not deleted, delete line commented out." >> $LOGDIR/logfile
        else
            upl_ok=0
            $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"`  "UPL: Copy failed. Keep raw data." >> $LOGDIR/logfile   
        fi
    else
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "UPL: No upload source available" >> $LOGDIR/logfile
    fi
}


start_upload()
{
    if [ -d $UPLSOURCEDIR ]
    then
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "UPL: Start upload to IOT" >> $LOGDIR/logfile
        #$USRBIN/rsync -a --timeout=300 -e='ssh -i /home/root/.ssh/terrameter_id_rsa' $UPLSOURCEDIR $IOT:$IOTDATADIR
		$USRBIN/rsync -a --timeout=300 -e='ssh -i '$SSHKEY $UPLSOURCEDIR $IOT:$IOTDATADIR
		$USRBIN/rsync -a --timeout=300 -e='ssh -i '$SSHKEY $WORKDIR/ $IOT:$IOTDATADIR/home_root/
             
        if [ $? -eq 0 ]
        then
             upl_ok=1
             $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "UPL: Upload done" >> $LOGDIR/logfile
             
             # We don't remove files after upload, only after copy to usb stick...
             
             #let delay_days=$RMRAWDELAY/1440
             #$BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "Delete raw data older than $delay_days day(s)." >> $LOGDIR/logfile
             #$USRBIN/find /media/hda1/projects/*/RawData/* -mmin +$RMRAWDELAY -exec rm {} \;
             # find and remove any files older than RMRAWDELAY minutes located in RawData folders 
             
             # then remove any empty subfolders starting with 00 and the RawData folders themselves
             # will only delete empty folders.
             #rmdir /media/hda1/projects/*/Rawdata/00*
             #rmdir /media/hda1/projects/*/Rawdata
             
             #$BIN/echo -n "DEBUGGING: Files not deleted, delete line commented out." >> $LOGDIR/logfile
        else
            upl_ok=0
            $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"`  "UPL: Upload failed." >> $LOGDIR/logfile   
        fi
    else
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "UPL: No upload source available" >> $LOGDIR/logfile
    fi
}


# This is the main program

if [[ -z $SCRIPTS_DIR ]]; then
    SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

source "$SCRIPTS_DIR/cronscripter_settings"
source "$SCRIPTS_DIR/helper_functions.sh"

start_usbcopy

test_ssh_connectivity "UPL"

if [ $ssh_ok -eq 1 ]
then
    start_upload
else
    $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "UPL: Could not connect." >> $LOGDIR/logfile   
    #$BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "UPL: Could not connect, set pending reboot!" >> $LOGDIR/logfile  
    #$HOME/set_pending_reboot.sh
fi


