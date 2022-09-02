#!/bin/bash


source "/home/root/cronscripter_settings"

#$BIN/echo "Resetting network" >> $LOGDIR/logfil
#/sbin/ifdown eth0 >> $LOGDIR/logfil 2>&1

#$BIN/echo "sleeping 30 sec" >> $LOGDIR/logfil
#sleep 30

#$BIN/echo "starting network" >> $LOGDIR/logfil
#/sbin/ifup eth0 >> $LOGDIR/logfil 2>&1
#$BIN/echo `route -n` >> $LOGDIR/logfile



$BIN/echo "Obtaining new lease on IP" >> $LOGDIR/logfil
$BIN/echo `udhcpc eth0` >> $LOGDIR/logfile 2>&1
$BIN/echo `route -n` >> $LOGDIR/logfile 


