#!/bin/bash

if !(service ntp status grep "active" &> /dev/null)
then 
echo "NOTICE: ntp is not running"
service ntp start
fi

function check {
echo "NOTICE: /etc/ntp.conf was changed. Calculated diff:";
diff -U 0 /etc/ntp.conf.bak  /etc/ntp.conf
cp /etc/ntp.conf.bak /etc/ntp.conf
}

if ! diff -q /etc/ntp.conf.bak /etc/ntp.conf &> /dev/null; then check; fi



