#!/bin/bash

sed -i '/^search example2.com$/d' /etc/resolv.conf
sed -i 's/ example2.com//' /etc/resolv.conf
