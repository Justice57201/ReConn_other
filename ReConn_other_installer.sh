#!/bin/bash
#
# By -- WRQC343 -- www.gmrs-link.com
# 
# Ver 1.0
#
# Installs ReConn files from GitHub repo
#

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "ERROR: Please run this installer as root"
  exit 1
fi


LINK="https://raw.githubusercontent.com/Justice57201/ReConn_other/main"
INSTALL_DIR="/etc/asterisk/local/ReConn"
MARKER_FILE="$INSTALL_DIR/.installed"
CRON_CMD="$INSTALL_DIR/ReConn.sh"

echo
echo "==== ReConn Installer ===="
echo

echo "Creating folders..."
mkdir -p "$INSTALL_DIR"/{tpl,Sound}
mkdir -p /usr/local/sbin/firsttime
echo "Folders created."
echo

download() {
  local url="$1"
  local dest="$2"
  local perms="${3:-755}"
  local file
  file="$(basename "$url")"

  echo "Downloading $file"
  wget -q --show-progress -O "$dest/$file" "$url" || {
    echo "ERROR: Failed to download $url"
    exit 1
  }
  chmod "$perms" "$dest/$file"
}


echo "Downloading menu file..."
download "$LINK/ft9-ReConn.sh" "/usr/local/sbin/firsttime" 755

echo "Downloading ReConn scripts..."
download "$LINK/ReConn/ReConn.sh" "$INSTALL_DIR" 755
download "$LINK/ReConn/ReConn-Enabled.sh" "$INSTALL_DIR" 755
download "$LINK/ReConn/ReConn-Disabled.sh" "$INSTALL_DIR" 755

echo "Downloading uninstaller..."
download "$LINK/uninstaller.sh" "$INSTALL_DIR" 755

echo "Downloading templates..."
download "$LINK/ReConn/tpl/ReConn.tpl" "$INSTALL_DIR/tpl" 644
download "$LINK/ReConn/tpl/ReConn-Enabled.tpl" "$INSTALL_DIR/tpl" 644
download "$LINK/ReConn/tpl/ReConn-Disabled.tpl" "$INSTALL_DIR/tpl" 644

echo "Downloading sound files..."
download "$LINK/ReConn/Sound/ReConn_Connecting.gsm" "$INSTALL_DIR/Sound" 644
download "$LINK/ReConn/Sound/ReConn_ENABLED.gsm" "$INSTALL_DIR/Sound" 644
download "$LINK/ReConn/Sound/ReConn_DISABLED.gsm" "$INSTALL_DIR/Sound" 644

echo "Downloads complete."
echo

echo "Configuring cron..."

if crontab -l 2>/dev/null | grep -q "$CRON_CMD"; then
  echo "ERROR: ReConn cron job already exists. Aborting."
  exit 1
fi

TMP_CRON="$(mktemp)"
crontab -l 2>/dev/null > "$TMP_CRON" || true
echo "*/10 * * * * $CRON_CMD" >> "$TMP_CRON"
crontab "$TMP_CRON"
rm -f "$TMP_CRON"

echo "Cron configured."
echo

read -rp "Enter Node Number #: " NODE
echo
read -rp "Enter ReConn Enable DTMF Code (eg: 917) #: " DTMF_ON
echo
read -rp "Enter ReConn Disable DTMF Code (eg: 918) #: " DTMF_OFF
echo

RPTCONF="/etc/asterisk/rpt.conf"

if ! grep -q ';ReConn1' "$RPTCONF" || ! grep -q ';ReConn0' "$RPTCONF"; then
  echo "ERROR: rpt.conf missing ;ReConn1 and/or ;ReConn0 markers"
  exit 1
fi

cp "$RPTCONF" "${RPTCONF}_$(date +%Y%m%d).bak"

sed -i \
  -e "s|;ReConn1|$DTMF_ON=cmd,/etc/asterisk/local/ReConn/ReConn-Enabled.sh|" \
  -e "s|;ReConn0|$DTMF_OFF=cmd,/etc/asterisk/local/ReConn/ReConn-Disabled.sh|" \
  "$RPTCONF"

echo "rpt.conf updated."
echo

SUPERMON_FILE=""

if [ -f "/srv/http/supermon2/user_files/controlpanel.ini" ]; then
  SUPERMON_FILE="/srv/http/supermon2/user_files/controlpanel.ini"
elif [ -f "/srv/http/supermon/controlpanel.ini" ]; then
  SUPERMON_FILE="/srv/http/supermon/controlpanel.ini"
fi

if [ -n "$SUPERMON_FILE" ]; then
  cp "$SUPERMON_FILE" "${SUPERMON_FILE}_$(date +%Y%m%d).bak"
  {
    echo "[$NODE]"
    echo 'labels[] = "ReConn Enable"'
    echo "cmds[] = \"rpt fun $NODE *$DTMF_ON\""
    echo 'labels[] = "ReConn Disable"'
    echo "cmds[] = \"rpt fun $NODE *$DTMF_OFF\""
  } >> "$SUPERMON_FILE"
  echo "Supermon updated."
else
  echo "Supermon not found — skipping."
fi
echo

date > "$MARKER_FILE"

if command -v asterisk >/dev/null 2>&1; then
  asterisk -rx "rpt reload" || true
  echo "Asterisk rpt reload sent."
fi

echo
echo "ReConn Install Complete"
exit 0
