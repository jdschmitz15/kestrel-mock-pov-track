#!/bin/bash
# Claims web tier: nginx in front of the Claims API, which reads SQL Express on kp-sql01.
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx python3-venv curl
#@file assets/app/claims_api.py /opt/claims/claims_api.py 0644
#@file assets/app/claims-api.service /etc/systemd/system/claims-api.service 0644
#@file assets/app/claims-nginx.conf /etc/nginx/sites-available/default 0644
#@file assets/bin/preflight.sh /usr/local/bin/preflight 0755
python3 -m venv /opt/claims/venv
/opt/claims/venv/bin/pip install --quiet flask gunicorn pymssql
systemctl daemon-reload
systemctl enable --now claims-api
systemctl restart nginx
