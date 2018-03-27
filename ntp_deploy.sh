#!/bin/bash
apt-get install -y ntp > /dev/null

sed -i "/^[[:blank:]]*pool/d" /etc/ntp.conf 
sed -i "/^[[:blank:]]*server/d" /etc/ntp.conf 

count=`cat /etc/ntp.conf |grep -n "# pool:" | awk -F: '{print $1}'`
let count=count+1
sed -i "$count"i\ 'server 0.ua.pool.ntp.org iburst prefer\nserver 1.ua.pool.ntp.org iburst\nserver 2.ua.pool.ntp.org iburst\nserver 3.ua.pool.ntp.org iburst' /etc/ntp.conf 

service ntp restart 

#crontab -l > mycron
#echo "*/5 * * * * /usr/sbin/ntpdate" >> mycron
#crontab mycron
#rm mycron
#crontab -l 2>/dev/nell | { cat; echo "*/5 * * * * ~/ntp_verify.sh"; } | crontab - 

cronTask="*/5 * * * * `pwd`/ntp_verify.sh"
(crontab -l 2>/dev/nell | grep -v -F "$cronTask" ; echo "$cronTask") | crontab -
