#!/bin/bash

DISPLAY=:0 sudo -u user2 /usr/local/bin/kerbnet.sh user2@EXAMPLE2.COM 10.5.0.11 &

if ! grep search > /dev/null /etc/resolv.conf; then
    echo 'search example2.com' >> /etc/resolv.conf
elif ! grep example2 > /dev/null /etc/resolv.conf; then
    sed -i 's/\(search.*\)/\1 example2.com/' /etc/resolv.conf
fi
