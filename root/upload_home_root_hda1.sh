#!/bin/sh

source ./cronscripter_settings

echo -e='ssh -i '$SSHKEY
$USRBIN/rsync -a --timeout=300 -e='ssh -i '$SSHKEY $WORKDIR/ $IOT:$IOTDATADIR/home_root/
$USRBIN/rsync -a --timeout=300 -e='ssh -i '$SSHKEY /media/hda1/ --exclude "projects" $IOT:$IOTDATADIR/hda1/

