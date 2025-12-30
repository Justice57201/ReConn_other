#!/bin/bash
#
# By -- WRQC343 -- www.gmrs-link.com
#
# Ver 1.0 - 10/23
#
#MENUFT%9%ReConn Setup
#

/usr/bin/cp /etc/asterisk/local/ReConn/tpl/ReConn.tpl /etc/asterisk/local/ReConn/ReConn.sh
/usr/bin/cp /etc/asterisk/local/ReConn/tpl/ReConn-Enabled.tpl /etc/asterisk/local/ReConn/ReConn-Enabled.sh
/usr/bin/cp /etc/asterisk/local/ReConn/tpl/ReConn-Disabled.tpl /etc/asterisk/local/ReConn/ReConn-Disabled.sh

 if ($D --colors --title "\ZB\Z7  ReConn Setup  \Zb" --yesno "\nReConn,\n\nWill help keep you connected to a hub/node\nin the event of connection loss.\n\nYou can enable or disable it with Supermon\nor a DTMF code.\n\n\Z2Do you wish to continue?\Zb" 15 55) then
$SON
  NODE=$($D --colors --title "\ZB\Z7  ReConn Setup  \Zb" --nocancel --inputbox "\nEnter Your Primary Node #:" 8 40 "$NODE1"  3>&1 1>&2 2>&3)
	ret=$?
      sed -i "s/XXXX/${NODE}/g" /etc/asterisk/local/ReConn/ReConn.sh
    	sed -i "s/XXXX/${NODE}/g" /etc/asterisk/local/ReConn/ReConn-Enabled.sh
      sed -i "s/XXXX/${NODE}/g" /etc/asterisk/local/ReConn/ReConn-Disabled.sh
 
  HUB=$($D --colors --title "\ZB\Z7  ReConn Setup  \Zb" --nocancel --inputbox "\nConnect to Hub/Node #:" 8 40 ""  3>&1 1>&2 2>&3)
	ret=$?
	    sed -i "s/0000/${HUB}/g" /etc/asterisk/local/ReConn/ReConn.sh
  	
fi