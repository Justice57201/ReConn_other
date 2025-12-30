#!/bin/bash
# 
# By -- WRQC343 -- www.gmrs-link.com
#
# Ver 1.5 - 8/20
# 
# This script allows you to periodically check to see if your node is 
# connected to another Hub/Node. 
#
# Example:
# 930=cmd,/etc/asterisk/local/ReConn/ReConn-Disabled.sh   ; Disable ReConn
# 931=cmd,/etc/asterisk/local/ReConn/ReConn-Enabled.sh   ; Enable ReConn
#
# NODE= Your node #
# HUB= Hub/node you are connecting to
#

NODE=XXXX
HUB=0000
DISABLEFILE="/etc/asterisk/local/ReConn/~ReConn_disabled"
LOGFILE="/var/log/asterisk/connectlog"
tempfile=/var/log/asterisk/temp-ReConn.$NODE


 if [ -f $DISABLEFILE ]
  then
      echo "* Disable flag * -- Exiting"
      exit
fi

      asterisk -rx "rpt nodes $NODE" > $tempfile

 grep -w "T$HUB" $tempfile > /dev/null ||
 CONNECTSTATUS=0

 grep -w "T$HUB" $tempfile > /dev/null &&
 CONNECTSTATUS=1

 if [[ "$CONNECTSTATUS" == "1" ]]
  then
      echo "$NODE is Connected to $HUB"

fi

 if [[ "$CONNECTSTATUS" == "0" ]]
  then
      echo "$NODE is Not Connected to $HUB"

      asterisk -rx "rpt fun $NODE *76"

sleep 3

      asterisk -rx "rpt localplay $NODE /etc/asterisk/local/ReConn/Sound/ReConn_Connecting"

sleep 8

      asterisk -rx "rpt fun $NODE *3$HUB"

      echo $(date) == $NODE Reconnected to $HUB via ReConn >> $LOGFILE
fi

exit