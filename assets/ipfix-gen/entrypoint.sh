#!/bin/sh
# Render the flow file from COLLECTOR (ip:port), WEB_IP and SQL_IP, then start the generator.
set -eu
: "${COLLECTOR:?set COLLECTOR to the NEN ip:port}" "${WEB_IP:?}" "${SQL_IP:?}"
export COLLECTOR_IP="${COLLECTOR%:*}" COLLECTOR_PORT="${COLLECTOR##*:}"
envsubst < /etc/kestrel/flows.yaml.tmpl > /etc/kestrel/flows.yaml
echo "Sending IPFIX to ${COLLECTOR_IP}:${COLLECTOR_PORT}"
exec netflow_generator --config /etc/kestrel/flows.yaml "$@"
