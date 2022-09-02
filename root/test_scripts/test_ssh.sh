#!/bin/bash

HOST=`ssh -i /home/root/.ssh/terrameter_id_rsa terrameter@192.168.23.1 hostname 2>&1`  

#HOST=`echo "HOST"`
echo `date` ":  $HOST  ($USER)" >> /home/root/testlog
