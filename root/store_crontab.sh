#!/bin/sh

if [[ -z $SCRIPTS_DIR ]]; then
    SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

source "$SCRIPTS_DIR/cronscripter_settings"


crontab -l > $CRONTABDIR/crontab_terrameter_`date "+%Y%m%d_%H%M%S(%Z)"`.txt

