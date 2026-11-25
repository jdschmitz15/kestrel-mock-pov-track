#!/bin/bash
# IPFIX exporter (no VEN): netflow_generator in Docker, sending to the NEN on kp-nen01:4739.
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y docker.io
systemctl enable --now docker
#@bundle assets/ipfix-gen /opt/ipfix-gen
docker build -t kestrel/ipfix-gen:v1 /opt/ipfix-gen
ip() { getent hosts "$1" | awk '{print $1; exit}'; }
for h in kp-nen01 kp-web01 kp-sql01; do
  for _ in $(seq 60); do [[ -n "$(ip "$h")" ]] && break; sleep 5; done
done
docker rm -f ipfix-gen 2>/dev/null || true
docker run -d --name ipfix-gen --restart unless-stopped \
  -e COLLECTOR="$(ip kp-nen01):4739" \
  -e WEB_IP="$(ip kp-web01)" \
  -e SQL_IP="$(ip kp-sql01)" \
  kestrel/ipfix-gen:v1 --interval 10
