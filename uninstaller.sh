#!/bin/bash
#
# By -- WRQC343 -- www.gmrs-link.com
#
# Ver 1.0 - ReConn Uninstaller
#

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo
echo "Starting ReConn Uninstall..."
echo

echo "Removing ReConn cron job..."
crontab -l 2>/dev/null | grep -v '/etc/asterisk/local/ReConn/ReConn.sh' > /tmp/crontab.tmp || true
crontab /tmp/crontab.tmp || true
rm -f /tmp/crontab.tmp
echo "Cron entry removed."
echo

RPTCONF="/etc/asterisk/rpt.conf"

if [ -f "$RPTCONF" ]; then
  echo "Restoring rpt.conf markers..."
  cp "$RPTCONF" "${RPTCONF}_uninstall_$(date +%Y%m%d).bak"

  sed -i \
    -e 's|^[0-9]\+=cmd,/etc/asterisk/local/ReConn/ReConn-Enabled.sh|;ReConn1|' \
    -e 's|^[0-9]\+=cmd,/etc/asterisk/local/ReConn/ReConn-Disabled.sh|;ReConn0|' \
    "$RPTCONF"

  echo "rpt.conf restored."
else
  echo "rpt.conf not found — skipping."
fi
echo

remove_supermon() {
  local file="$1"
  echo "Cleaning Supermon file: $file"
  cp "$file" "${file}_uninstall_$(date +%Y%m%d).bak"

  sed -i '/ReConn Enable/,+1d' "$file"
  sed -i '/ReConn Disable/,+1d' "$file"
}

if [ -f "/srv/http/supermon2/user_files/controlpanel.ini" ]; then
  remove_supermon "/srv/http/supermon2/user_files/controlpanel.ini"
elif [ -f "/srv/http/supermon/controlpanel.ini" ]; then
  remove_supermon "/srv/http/supermon/controlpanel.ini"
else
  echo "No Supermon controlpanel.ini found — skipping."
fi
echo

echo "Removing ReConn files..."
rm -rf /etc/asterisk/local/ReConn
rm -rf /usr/local/sbin/firsttime/ft9-ReConn.sh
echo "Files removed."
echo

if command -v asterisk >/dev/null 2>&1; then
  echo "Reloading Asterisk rpt module..."
  asterisk -rx "rpt reload" || true
else
  echo "Asterisk not found — skipping reload."
fi
echo

echo "ReConn Uninstall - Complete"
exit 0
