#!/bin/bash
#
# By -- WRQC343 -- www.gmrs-link.com
#
# Ver 1.0 - 
#
# Ver 1.7 - adapted 11/16/2025
#
# Installs ReConn files from GitHub repo

set -euo pipefail

link="https://raw.githubusercontent.com/Justice57201/ReConn_other/main"

echo
echo "Creating folders..."
mkdir -p /etc/asterisk/local/ReConn/tpl
mkdir -p /etc/asterisk/local/ReConn/Sound
mkdir -p /usr/local/sbin/firsttime

echo "Folders - Complete"
echo

download() {
  local url="$1"
  local dest_dir="$2"
  local perms="${3:-755}"
  echo "Downloading $(basename "$url") -> $dest_dir"
  wget -q --show-progress -O "${dest_dir%/}/$(basename "$url")" "$url" || { echo "Failed to download $url"; exit 1; }
  chmod "$perms" "${dest_dir%/}/$(basename "$url")"
}

echo "Downloading Menu File"
download "$link/ft9-ReConn.sh" "/usr/local/sbin/firsttime" 755
echo "Menu File - Complete"
echo

echo "Downloading ReConn Files"
download "$link/ReConn/ReConn.sh" "/etc/asterisk/local/ReConn" 755
download "$link/ReConn/ReConn-Enabled.sh" "/etc/asterisk/local/ReConn" 755
download "$link/ReConn/ReConn-Disabled.sh" "/etc/asterisk/local/ReConn" 755
echo "ReConn Files - Complete"
echo

echo "Downloading Template Files"
download "$link/ReConn/tpl/ReConn.tpl" "/etc/asterisk/local/ReConn/tpl" 644
download "$link/ReConn/tpl/ReConn-Enabled.tpl" "/etc/asterisk/local/ReConn/tpl" 644
download "$link/ReConn/tpl/ReConn-Disabled.tpl" "/etc/asterisk/local/ReConn/tpl" 644
echo "Template Files - Complete"
echo

echo "Downloading Sound Files"
download "$link/ReConn/Sound/ReConn_Connecting.gsm" "/etc/asterisk/local/ReConn/Sound" 644
download "$link/ReConn/Sound/ReConn_ENABLED.gsm" "/etc/asterisk/local/ReConn/Sound" 644
download "$link/ReConn/Sound/ReConn_DISABLED.gsm" "/etc/asterisk/local/ReConn/Sound" 644
echo "Sound Files - Complete"
echo

# Backup current crontab (root)
if [ -f /var/spool/cron/root ]; then
  cp /var/spool/cron/root /var/spool/cron/root_"$(date +%Y%m%d)".bak || true
fi
echo "Cron Backup - Complete"
echo

# Check cron for existing entry
if crontab -l 2>/dev/null | grep -q '/etc/asterisk/local/ReConn/ReConn.sh'; then
  echo "An entry for ReConn.sh already exists in cron. Aborting to avoid duplicate."
  exit 1
fi

# Add cron entry
crontab -l 2>/dev/null > /tmp/crontab.tmp || true
echo '*/10 * * * * /etc/asterisk/local/ReConn/ReConn.sh' >> /tmp/crontab.tmp
crontab /tmp/crontab.tmp
rm -f /tmp/crontab.tmp
echo "Cron File - Complete"
echo

# Prompt for node and DTMF codes
read -rp "Enter Node Number #: " var1
echo
read -rp "Enter ReConn Enable DTMF Code (eg: 917) #: " var2
echo
read -rp "Enter ReConn Disable DTMF Code (eg: 918) #: " var3
echo

# Check rpt.conf markers
if ! grep -q '\;ReConn1' /etc/asterisk/rpt.conf 2>/dev/null || ! grep -q '\;ReConn0' /etc/asterisk/rpt.conf 2>/dev/null; then
  echo "rpt.conf does not contain required markers ';ReConn1' and ';ReConn0'. Please add them and re-run."
  exit 1
fi
echo "rpt.conf markers found."
echo

# Backup rpt.conf
cp /etc/asterisk/rpt.conf /etc/asterisk/rpt.conf_"$(date +%Y%m%d)".bak
echo "rpt.conf backup created."
echo

# Replace markers with DTMF command lines
sed -e "s/;ReConn1/${var2}=cmd,\\/etc\\/asterisk\\/local\\/ReConn\\/ReConn-Enabled.sh/" \
    -e "s/;ReConn0/${var3}=cmd,\\/etc\\/asterisk\\/local\\/ReConn\\/ReConn-Disabled.sh/" \
    -i /etc/asterisk/rpt.conf

echo "rpt.conf updated."
echo

# Detect Supermon installation and back up controlpanel.ini
if [ -d "/srv/http/supermon2" ]; then
  supermon_version="supermon2"
  config_path="/srv/http/supermon2/user_files/controlpanel.ini"
elif [ -d "/srv/http/supermon" ]; then
  supermon_version="supermon"
  config_path="/srv/http/supermon/controlpanel.ini"
else
  echo "No Supermon installation found. Skipping controlpanel.ini changes."
  supermon_version=""
  config_path=""
fi

if [ -n "$config_path" ]; then
  cp "$config_path" "${config_path}_$(date +%Y%m%d).bak"
  {
    echo "[$var1]"
    echo 'labels[] = "ReConn Enable"'
    echo "cmds[] = \"rpt fun $var1 *$var2\""
    echo 'labels[] = "ReConn Disable"'
    echo "cmds[] = \"rpt fun $var1 *$var3\""
  } >> "$config_path"
  echo "controlpanel.ini updated for $supermon_version."
fi

echo
echo "Reloading Asterisk rpt module (if Asterisk installed)..."
if command -v asterisk >/dev/null 2>&1; then
  asterisk -rx "rpt reload" || true
  echo "Asterisk rpt reload attempted."
else
  echo "Asterisk not found — skipping rpt reload."
fi

echo
echo "ReConn Install - Complete"
exit 0
