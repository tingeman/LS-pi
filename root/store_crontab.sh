#!/bin/sh

crontab -l > /home/root/crontab_terrameter_`date "+%Y%m%d_%H%M%S(%Z)"`.txt

