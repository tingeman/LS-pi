#!/bin/bash

source "$HOME/cronscripter_settings"

touch $LOGDIR/logfile
$BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "====== Terrameter booted ======" >> $LOGDIR/logfile 



