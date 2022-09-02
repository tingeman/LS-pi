#/bin/sh

################################################
#copy network configuration (IP address) to NAS 


source "./cronscripter_settings"
source "./helper_functions.sh"

touch $LOGDIR/logfile

check_if_terrameter_runs "SIP"

if [ $running -eq 0 ]
then
    test_ssh_connectivity "SIP"

    if [ $ssh_ok -eq 1 ]
    then
        /sbin/ifconfig > $WORKDIR/ifconfig_terrameter.txt
    echo "# " `date "+%Y-%m-%d %H:%M:%S(%Z)"` >> $WORKDIR/ifconfig_terrameter.txt
        $SCP $WORKDIR/ifconfig_terrameter.txt $IOT:$IOTDIR
        $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "SIP: file with IP sent." >> $LOGDIR/logfile
    fi
else
    $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "SIP: Terrameter runs => Die." >> $LOGDIR/logfile
fi
