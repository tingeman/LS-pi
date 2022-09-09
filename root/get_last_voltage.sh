#!/bin/bash

if [[ -z $SCRIPTS_DIR ]]; then
    SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

source "$SCRIPTS_DIR/cronscripter_settings"


projdir=`ls -1dr /media/hda1/projects/2* | head -n 1`
echo "project: $projdir"
echo `/usr/bin/sqlite3 $projdir/project.db < "$SCRIPTS_DIR"/sql_commands/GET_VOLTAGE.sql`

