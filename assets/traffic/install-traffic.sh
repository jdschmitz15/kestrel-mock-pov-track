#!/bin/bash
# Install traffic-generator and run it in "continuous" mode from /opt/traffic/traffic.csv.
# The host listens on every row where it is dst and connects on every row where it is src.
# Usage: install-traffic.sh   (expects /opt/traffic/traffic.csv to exist)
set -euo pipefail
TG_VERSION=${TG_VERSION:-1.0.5}
TG_URL="https://github.com/jdschmitz15/traffic-generator/releases/download/v$TG_VERSION/linux_amd64.zip"
if [[ ! -x /usr/local/bin/traffic-generator ]]; then
  tmp=$(mktemp -d)
  curl -fsSL --retry 3 -o "$tmp/tg.zip" "$TG_URL"
  python3 -c 'import sys, zipfile; zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])' "$tmp/tg.zip" "$tmp"
  install -m 0755 "$tmp/linux_amd64/traffic-generator" /usr/local/bin/traffic-generator
  rm -rf "$tmp"
fi
cat > /etc/systemd/system/traffic-generator.service <<'UNIT'
[Unit]
Description=Kestrel lab traffic (traffic-generator continuous)
After=network-online.target
Wants=network-online.target
[Service]
WorkingDirectory=/opt/traffic
Environment=TRAFFIC_GENERATOR_LOG_FILE=/var/log/traffic-generator.log
ExecStart=/usr/local/bin/traffic-generator continuous /opt/traffic/traffic.csv
Restart=always
RestartSec=10
[Install]
WantedBy=multi-user.target
UNIT
# Open this host's listener ports if firewalld is running (Rocky).
if systemctl is-active --quiet firewalld; then
  me=$(hostname -s)
  awk -F, -v me="$me" 'NR>1 && $2==me {print $3"/"$4}' /opt/traffic/traffic.csv | sort -u |
    while read -r p; do firewall-cmd --permanent --add-port="$p"; done
  firewall-cmd --reload
fi
systemctl daemon-reload
systemctl enable traffic-generator
systemctl restart traffic-generator
echo "traffic-generator running; log: /var/log/traffic-generator.log"
