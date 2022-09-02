#!/bin/sh

source ./cronscripter_settings

echo -e='ssh -i '$PRIVATEKEY
$USRBIN/rsync -a --timeout=300 -e='ssh -i '$PRIVATEKEY /home/root/ $IOT:$IOTDATADIR/home_root/
$USRBIN/rsync -a --timeout=300 -e='ssh -i '$PRIVATEKEY /media/hda1/ --exclude "projects" $IOT:$IOTDATADIR/hda1/

