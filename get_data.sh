#!/bin/bash
# Collects some metrics and information about the system for the end user to send to us in a ticket.
# Version 1.0 by Jarrod Coombes
#       - Initial Implimentation
# Version 1.0.1
#       - Reworked the script for an easier to read log file
#       - Removed the traceroute test.
#       - Added DNS server ping test.
#       - Added DNS lookup test.
#       - Added MacOS Version
#       - Added Uptime

user=$(who | grep "console" | awk  '{print $1}')
today=$(date)

hname=$(scutil --get HostName)
lhname=$(scutil --get LocalHostName)
cname=$(scutil --get ComputerName)
macosver=$(sw_vers -productVersion)
up=$(uptime | awk -F'( |,|:)+' '{print $4,$5",",$6,"hours,",$7,"minutes."}')


logfile=/Users/$user/Desktop/NetworkInfo.txt

echo "---------------------------------------------------------------------" >> $logfile
echo $today >> $logfile
echo >> $logfile
echo "MacOS Version:     " $macosver >> $logfile
echo "Computer uptime:   " $up >> $logfile
echo "Logged in user is: " $user >> $logfile
echo "Hostname is:       " $hname >> $logfile
echo "Local Hostname is: " $lhname >> $logfile
echo "Computer name is:  " $cname >> $logfile

echo >> $logfile

echo "CPU Usage over 10 seconds, taken at 2 second intervals: " >> $logfile
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

echo "Wireless Information:" >> $logfile
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I >> $logfile

echo >> $logfile

echo >> "Network Test Results:" >> $logfile

gw=$(route get 8.8.8.8 | grep gateway | awk '{print $2}')
echo "Ping response from the Gateway ("$gw"):" >> $logfile
echo >> $logfile
ping -c 10 $gw >> $logfile

echo >> $logfile

dns=$(scutil --dns | grep 'nameserver\[[0]*\]' | awk '{print $3; exit}')
echo "Ping response from the DNS server ("$dns"):" >> $logfile
echo >> $logfile
ping -c 10 $dns >> $logfile

echo >> $logfile

echo "Ping response from Google.com:" >> $logfile
echo >> $logfile
ping -c 10 google.com >> $logfile

echo >> $logfile

echo "Name resolution test results" >> $logfile
echo >> $logfile
echo "For mpcsd.org:" >> $logfile
nslookup mpcsd.org >> $logfile
echo >> $logfile
echo "For apple.com:" >> $logfile
nslookup apple.com >> $logfile

echo >> $logfile


echo "Speed test results:" >> $logfile
/usr/local/bin/speedtest-cli >> $logfile


echo >> $logfile
echo >> $logfile