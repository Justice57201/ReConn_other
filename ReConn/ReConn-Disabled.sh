#!/bin/bash
#
# By -- WRQC343 -- www.gmrs-link.com
#
# Ver 1.0 - 10/23
#

    touch /etc/asterisk/local/ReConn/~reconn_disabled
    asterisk -rx "rpt localplay XXXX /etc/asterisk/local/ReConn/Sound/ReConn_DISABLED"