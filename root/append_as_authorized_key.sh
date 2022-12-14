#!/bin/bash

if [[ -z $SCRIPTS_DIR ]]; then
    SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

source "$SCRIPTS_DIR/cronscripter_settings"


cat "$SSHKEY".pub | ssh $IOT "mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys; cat >> ~/.ssh/authorized_keys"

if [[ $? -eq 0 ]]; then
    echo "SSH key has been added to the authorized_keys of the host."
    echo "Test access with the command: ssh -i $SSHKEY $IOT"
else
    echo "Could not add key to hosts authorized keys!"
    echo "Please do it manually."
fi


dhcpd_conf=$(ssh -i $SSHKEY $IOT "cat /etc/dhcp/dhcpd.conf")

if [[ $(hostname) == LSsimulator ]]; then
    if [[ -z $(echo "$dhcpd_conf" | grep 'LSsimulator') ]]; then
        mac_address=`ifconfig | sed -n '/^eth0:/,/^$/ { s/ether[[:blank:]]*\([^[:blank:]]*\).*/\1/p  }'`
        ip_address=`ifconfig | sed -n '/^eth0:/,/^$/ { s/inet [[:blank:]]*\([^[:blank:]]*\).*/\1/p  }'`    # the trailing space after 'inet' is important to distinguish from inet6
        
        echo ' '
        echo 'You should add the follwoing lines to the upstream server /etc/dhcp/dhcpd.conf file (sudo nano /etc/dhcp/dhcpd.conf):'
        echo ' '
        echo "host $hostname {"
        echo "  hardware ethernet $(mac_address);"
        echo "  fixed-address ${ip_address};"
        echo "}"
        echo ' '
    fi
else
    if [[ -z $(echo "$dhcpd_conf" | grep 'LS209110003') ]]; then
        mac_address=`ifconfig | sed -n '/^eth0/,/^$/ { s/ether[[:blank:]]*\([^[:blank:]]*\).*/\1/p  }'`
        ip_address=`ifconfig | sed -n '/^eth0/,/^$/ { s/inet [[:blank:]]*addr:\([^[:blank:]]*\).*/\1/p  }'`
        
        echo ' '
        echo 'You should add the follwoing lines to the upstream server /etc/dhcp/dhcpd.conf file (sudo nano /etc/dhcp/dhcpd.conf):'
        echo ' '
        echo "host $hostname {"
        echo "  hardware ethernet $(mac_address);"
        echo "  fixed-address ${ip_address};"
        echo "}"
        echo ' '
    fi
fi

