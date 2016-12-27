#!/bin/sh

SHELLROOT=`pwd`
#SERVERIP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
SERVERIP=`ifconfig  eth0 | grep "inet addr" | awk -F":" '{ print $2 }' | cut -f1 -d" "`
LSCPHOME="/usr/local/lscp/result_html"
YESTERDAY=`date -d '1 day ago' +%y.%m.%d`
TODAY=`date +'%y.%m.%d'`

if [ -f "$SHELLROOT/beforeLSCPReport.html" ] ; then
        echo "exist"
else
        cp -pa $LSCPHOME/day_check_$YESTERDAY/error_report.html $SHELLROOT/beforeLSCPReport.html
fi

cp -pa $LSCPHOME/day_check_$TODAY/error_report.html $SHELLROOT/nowLSCPReport.html

FILECHARSET=`file -i $SHELLROOT/nowLSCPReport.html | cut -d "=" -f 2`

if [ "$FILECHARSET" != "utf-8" ] ; then
        echo "iconv"
        iconv -c -f cp949 -t utf-8 $SHELLROOT/nowLSCPReport.html > $SHELLROOT/nowLSCPReport.html.tmp && mv $SHELLROOT/nowLSCPReport.html.tmp $SHELLROOT/nowLSCPReport.html
fi

##############################################################################

# File Check
CHECKSTR=`grep -i "h3" $SHELLROOT/nowLSCPReport.html`
if [ "$CHECKSTR" = "" ] ; then
        CHECK=0 # CHECK variables initialize (0:logger not execute, 1:logger execute)
else
        CHECK=1
fi

# rsyslog
if [ "$CHECK" = "1" ] ; then
        logger -p local6.alert -s "Check LSCP Reports - $CHECKSTR (http://$SERVERIP:19999/lscp/day_check_$TODAY/error_report.html)"
fi

##############################################################################

# report file change
rm -f $SHELLROOT/beforeLSCPReport.html
mv $SHELLROOT/nowLSCPReport.html $SHELLROOT/beforeLSCPReport.html

# lscp initializing
/usr/local/lscp/bin/lscp_init
