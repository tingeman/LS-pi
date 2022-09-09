#!/bin/bash

source ./cronscripter_settings

cat "$SSHKEY".pub | ssh $IOT "mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys; cat >> ~/.ssh/authorized_keys"

if [[ $? -eq 0]]; then
    echo "SSH key has been added to the authorized_keys of the host."
    echo "Test access with the command: ssh -i $SSHKEY $IOT"
else
    echo "Could not add key to hosts authorized keys!"
    echo "Please do it manually."
