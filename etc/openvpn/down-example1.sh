#!/bin/bash

sed -i '/^search example1.org dip.example1.org$/d' /etc/resolv.conf
sed -i 's/ example1.org dip.example1.org//' /etc/resolv.conf
