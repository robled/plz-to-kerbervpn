#!/bin/bash

DISPLAY=:0 sudo -u user1 /usr/local/bin/kerbnet.sh user1@EXAMPLE1.ORG 172.31.31.3 &

if ! grep search > /dev/null /etc/resolv.conf; then
    echo 'search example1.org dip.example1.org' >> /etc/resolv.conf
elif ! grep example1 > /dev/null /etc/resolv.conf; then
    sed -i 's/\(search.*\)/\1 example1.org dip.example1.org/' /etc/resolv.conf
fi
