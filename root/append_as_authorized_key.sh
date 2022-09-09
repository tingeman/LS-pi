#!/bin/bash

source ./cronscripter_settings

cat "$SSHKEY".pub | ssh $IOT "mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys; cat >> ~/.ssh/authorized_keys"
