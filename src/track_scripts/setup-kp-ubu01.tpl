#!/bin/bash
# Ubuntu VEN practice host: netcat listener on 8443.
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y netcat-openbsd curl
#@file assets/bin/preflight.sh /usr/local/bin/preflight 0755
cat > /etc/systemd/system/kestrel-nc.service <<'UNIT'
[Unit]
Description=Kestrel netcat listener on 8443
After=network-online.target
[Service]
ExecStart=/bin/nc -lk 8443
Restart=always
[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now kestrel-nc
