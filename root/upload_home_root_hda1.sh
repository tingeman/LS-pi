#!/bin/sh

if [[ -z $SCRIPTS_DIR ]]; then
    SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

source "$SCRIPTS_DIR/cronscripter_settings"


echo -e='ssh -i '$SSHKEY
$USRBIN/rsync -a --timeout=300 -e='ssh -i '$SSHKEY $WORKDIR/ $IOT:$IOTDATADIR/home_root/
$USRBIN/rsync -a --timeout=300 -e='ssh -i '$SSHKEY /media/hda1/ --exclude "projects" $IOT:$IOTDATADIR/hda1/

