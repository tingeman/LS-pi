#!/bin/bash


## Get current date and time
_now=$(date +"%Y%m%d_%H%M%S")

## Appending a current date from a $_now to a filename stored in $_file
_file="/home/root/test_data/test_$_now.txt"

echo "this is a test" > "$_file"

HOSTIP="192.168.23.1"
USER="terrameter"
KEYPATH="/home/root/.ssh/terrameter_id_rsa"
SOURCEPATH="/home/root/test_data/"
DESTPATH="/mnt/sdcard/QEQ-ERT-02_test_data/"

rsync -avz --no-perms -e "ssh -i ${KEYPATH}" ${SOURCEPATH} ${USER}@${HOSTIP}:${DESTPATH}

