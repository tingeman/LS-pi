#!/bin/sh

source ./cronscripter_settings

crontab -l > $CRONTABDIR/crontab_terrameter_`date "+%Y%m%d_%H%M%S(%Z)"`.txt

