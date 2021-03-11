#!/bin/bash

user=$(who | grep "console" | awk  '{print $1}')


logfile=/Users/$user/Desktop/NetworkInfo.txt

today=$(date)

echo $today " - Getting Network Data:" >> $logfile

echo >> $logfile
echo "---------------------------------------------------------------------" >> $logfile
echo >> $logfile

echo "Logged in user is: " $user >> $logfile

echo >> $logfile
echo "---------------------------------------------------------------------" >> $logfile
echo >> $logfile


echo "Connected network Devices and info: " >> $logfile

while read -r line; do
    sname=$(echo "$line" | awk -F  "(, )|(: )|[)]" '{print $2}')
    sdev=$(echo "$line" | awk -F  "(, )|(: )|[)]" '{print $4}')
    #echo "Current service: $sname, $sdev, $currentservice"
    if [ -n "$sdev" ]; then
        ifout="$(ifconfig "$sdev" 2>/dev/null)"
        echo "$ifout" | grep 'status: active' > /dev/null 2>&1
        rc="$?"
        if [ "$rc" -eq 0 ]; then
            currentservice="$sname"
            currentdevice="$sdev"
            currentmac=$(echo "$ifout" | awk '/ether/{print $2}')
            currentip=$(ifconfig "$sdev" | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}')

            # may have multiple active devices, so echo it here
            echo "$currentservice, $currentdevice, $currentmac, $currentip" >> $logfile
        fi
    fi
done <<< "$(networksetup -listnetworkserviceorder | grep 'Hardware Port')"

if [ -z "$currentservice" ]; then
    >&2 echo "Could not find current service" >> $logfile
    exit 1
fi

echo >> $logfile
echo "---------------------------------------------------------------------" >> $logfile
echo >> $logfile

echo "Wireless Information:" >> $logfile
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I >> $logfile

echo >> $logfile
echo "---------------------------------------------------------------------" >> $logfile
echo >> $logfile

gw=$(route get 8.8.8.8 | grep gateway | awk '{print $2}')
echo "Pinging the Gateway ("$gw"):" >> $logfile
ping -c 10 $gw >> $logfile

echo >> $logfile
echo "---------------------------------------------------------------------" >> $logfile
echo >> $logfile

echo "Pinging Google.com:" >> $logfile
echo >> $logfile
ping -c 10 google.com >> $logfile

echo >> $logfile
echo "---------------------------------------------------------------------" >> $logfile
echo >> $logfile

echo "Running a trace to Google.com:" >> $logfile
echo >> $logfile
traceroute google.com >> $logfile

echo >> $logfile
echo "---------------------------------------------------------------------" >> $logfile
echo >> $logfile

echo "CPU Usage Info: " >> $logfile
cpuuse=$(top -l 1 | grep -E "^CPU")
echo $cpuuse >> $logfile
sleep 2
cpuuse=$(top -l 1 | grep -E "^CPU")
echo $cpuuse >> $logfile
sleep 2
cpuuse=$(top -l 1 | grep -E "^CPU")
echo $cpuuse >> $logfile
sleep 2
cpuuse=$(top -l 1 | grep -E "^CPU")
echo $cpuuse >> $logfile
sleep 2
cpuuse=$(top -l 1 | grep -E "^CPU")
echo $cpuuse >> $logfile
sleep 2
cpuuse=$(top -l 1 | grep -E "^CPU")
echo $cpuuse >> $logfile


echo >> $logfile
echo "---------------------------------------------------------------------" >> $logfile
echo >> $logfile

echo "Running Speed test:" >> $logfile
speedtest-cli >> $logfile




echo >> $logfile
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
echo >> $logfile

