#!/bin/bash

if !(service ntp status grep "active" >> /dev/null)
then 
service ntp start
fi

mapfile -d$'\n' -t strings < <(echo 'server 0.ua.pool.ntp.org iburst prefer
server 1.ua.pool.ntp.org iburst
server 2.ua.pool.ntp.org iburst
server 3.ua.pool.ntp.org iburst')

IFS=$'\n'
i=0
j=0
k=0

function check {
if [ "$j" -eq 0 ]; then echo "Change rows:"; let j=1; fi
echo "$1"
}

rowsPool=`cat /etc/ntp.conf | grep -i -E '^[[:blank:]]*pool [0-9]'`
if [ -n "$rowsPool" ]; then check "$rowsPool"; fi

for var in $(cat /etc/ntp.conf | grep -i -E '^[[:blank:]]*Server')
do
varNotSpace=`echo $var | sed 's/\s\+$//'| sed 's/^\s\+//'`
if [ "$varNotSpace" != "${strings[$i]}" ] 2> /dev/null
then
check "$var"
else
let k=k+1
fi
let i=i+1
done

if [ "$j" -gt 0 ] || [ "$k" -ne 4 ]; then
sed -i "/^[[:blank:]]*pool/d" /etc/ntp.conf 
sed -i "/^[[:blank:]]*server/d" /etc/ntp.conf 
count=`cat /etc/ntp.conf |grep -n "# pool:" | awk -F: '{print $1}'`
if [ "$count" -gt 0 ] 2> /dev/null
then let count=count+1
else count=`cat /etc/ntp.conf | wc -l`
fi
sed -i "$count"i\ 'server 0.ua.pool.ntp.org iburst prefer\nserver 1.ua.pool.ntp.org iburst\nserver 2.ua.pool.ntp.org iburst\nserver 3.ua.pool.ntp.org iburst' /etc/ntp.conf 
service ntp restart
fi

