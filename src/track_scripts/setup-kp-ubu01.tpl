#!/bin/bash
# Ubuntu VEN practice host: traffic-generator listens on 8443 and talks to its neighbours.
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y curl python3
#@file assets/bin/preflight.sh /usr/local/bin/preflight 0755
# Lab traffic between the servers (rows in assets/traffic/traffic.csv)
#@file assets/traffic/traffic.csv /opt/traffic/traffic.csv 0644
#@file assets/traffic/install-traffic.sh /usr/local/sbin/install-traffic 0755
/usr/local/sbin/install-traffic
