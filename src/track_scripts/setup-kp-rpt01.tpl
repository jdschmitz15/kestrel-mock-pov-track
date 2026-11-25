#!/bin/bash
# Reporting server: queries the Claims database directly on 1433 every 5 minutes (the finding).
set -euxo pipefail
dnf install -y python3-pip cronie curl
#@file assets/app/report_job.py /opt/report/report_job.py 0644
#@file assets/bin/preflight.sh /usr/local/bin/preflight 0755
python3 -m venv /opt/report/venv
/opt/report/venv/bin/pip install --quiet pymssql
echo '*/5 * * * * root /opt/report/venv/bin/python /opt/report/report_job.py >> /var/log/kestrel-report.log 2>&1' > /etc/cron.d/kestrel-report
systemctl enable --now crond
# Lab traffic between the servers (rows in assets/traffic/traffic.csv)
#@file assets/traffic/traffic.csv /opt/traffic/traffic.csv 0644
#@file assets/traffic/install-traffic.sh /usr/local/sbin/install-traffic 0755
/usr/local/sbin/install-traffic
