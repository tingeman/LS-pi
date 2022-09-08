#!/bin/bash

source ./cronscripter_settings

cat "$SSHKEY".pub | ssh $IOT "cat >> .ssh/authorized_keys"


