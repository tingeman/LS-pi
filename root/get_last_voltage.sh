#!/bin/bash


source "/home/root/cronscripter_settings"

projdir=`ls -1dr /media/hda1/projects/2* | head -n 1`
echo "project: $projdir"
echo `/usr/bin/sqlite3 $projdir/project.db < GET_VOLTAGE.sql`

