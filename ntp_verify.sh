#!/bin/bash

# commentblock.sh


if !(service ntp status grep "active" >> /dev/null)
then 
echo "NOTICE: ntp is not running"
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
if [ "$j" -eq 0 ]; then echo "NOTICE: /etc/ntp.conf was changed. Calculated diff:"; let j=1; fi
#echo `cat /etc/ntp.conf | grep -in -E "$1"` | awk -F: '{print $1}'
echo "@@ -$2 +$2 @@"
if [ -n "$3" ]; then echo "-"$3; fi
echo "+"$1
}

for var in $(cat /etc/ntp.conf | grep -in -E '^[[:blank:]]*pool')
do
countRows=`echo $var | awk -F: '{print $1}'`
rowsPool=`echo $var | awk -F'^[0-9]+:' '{print $2}'`
check "$rowsPool" "$countRows"
done

for var in $(cat /etc/ntp.conf | grep -in -E '^[[:blank:]]*Server')
do
countRows=`echo $var | awk -F: '{print $1}'`
rows=`echo $var | awk -F'^[0-9]+:' '{print $2}'`
varNotSpace=`echo $rows | sed 's/\s\+$//'| sed 's/^\s\+//'`
if [ "$varNotSpace" != "${strings[$i]}" ] 2> /dev/null
then
#check "$varNotSpace" "${strings[$i]}"
check "$rows" "$countRows" "${strings[$i]}"
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


#: << COMMENTBLOCK
#for var in "$(cat /etc/ntp.conf)"
#do 
#echo "$var"
#echo "qwe";
#done

#while read line
#do
#echo $line
#done < "/etc/ntp.conf"
#COMMENTBLOCK


