#!/bin/bash


# Should not react to:
#
# SLEEP
# WAITMEASURE
# WAITHOUR
# WAITHALFHOUR
# LCDOFF
# LCDON
# P_NEWDA
# NEW_PROJECT
# UPLOAD
# SIGNALCOMPLETE
# SQLITE
#
#
# MUST REACT TO:
#
# s unattendedmode 1
# T 2x21wenner /home/root/protocols/2X21.xml  /home/root/protocols/Wenner2x21.xml 2 2 1 0 0 0
# S 0 0 0
# m
# g measure
# R
# Q

############################################
##     ABEM Terrameter LS Console commands
##
##     Commands:
##     g    Get
##     s    Set
##     L    List all Projects
##     P    Create a new project
##     O    Open a project
##     T    Create a new task
##     S    Create a new station
##     W    Write settings to xml file
##     w    Read settings from xml file
##     R    Show recent measure results
##     A    Show all results
##     m    Start/Stop (m)easuring process
##     G    Print GPS information
##     I    Set system time from GPS
##     U    Prepare transmitter for software update
##     ?    Help = Show this message
##     H    Help = Show this message
##     Q    Quit
##
############################################




source ./cronscripter_settings

# Check to see if a pipe exists on stdin.
if [[ -p /dev/stdin ]]; then
    echo "Data was piped to this script!"
    # If we want to read the input line by line
    while IFS= read line; do
        
        echo "Line: ${line}"

        if echo ${line} | grep -Eq '^s '; then
            echo "Simulating setting parameter..."
        elif echo ${line} | grep -Eq '^P '; then
            echo "Simulating creating new project..."
            dirname=$(awk '{print $2}')
            mkdir -p ${UPLSOURCEDIR}/$dirname
            touch ${UPLSOURCEDIR}/${dirname}/project.db.txt
        elif echo ${line} | grep -Eq '^T '; then
            echo "Simulating creating new task..."
        elif echo ${line} | grep -Eq '^S '; then
            echo "Simulating creating new station..."
        elif echo ${line} | grep -Eq '^m'; then
            echo "Simulating starting measuring process..."
        elif echo ${line} | grep -Eq '^g measure'; then
            echo "Simulating getting current measure..."  
            echo "measure        0"
        elif echo ${line} | grep -Eq '^R'; then
            echo "Measure Results:"
            echo "Showing results for latest measure (id=10)"
            echo "Ch  Seq  Type             ADValue    Range  Value   Unit  S.Dev"
            echo "--  ---  ---------------  ---------  -----  ------  ----  -----"
            echo "Simulating showing current measure result..."
            echo " "
        elif echo ${line} | grep -Eq '^Q'; then
            echo "Quitting the script"
            exit 0
        else
            echo "I don't know this command!"
        fi

    done
    # Or if we want to simply grab all the data, we can simply use cat instead
    # cat
else
    echo "No input was found on stdin, skipping!"
    # Checking to ensure a filename was specified and that it exists
    if [ -f "$1" ]; then
        echo "Filename specified: ${1}"
        echo "Doing things now.."
    else
        echo "No input given!"
    fi
fi



