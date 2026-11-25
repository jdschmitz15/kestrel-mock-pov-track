#!/usr/bin/env bash
# Pre-flight check for one Linux host. Usage: preflight <pce-hostname>[:port]
set -uo pipefail
target=${1:?usage: preflight <pce-hostname>[:port]}
host=${target%%:*}; port=${target##*:}; [[ $port == "$host" ]] && port=443
. /etc/os-release
os="$ID $VERSION_ID"
case "$ID" in
  ubuntu)   [[ ${VERSION_ID%%.*} -ge 18 ]] && sup=yes || sup=no ;;
  debian)   [[ ${VERSION_ID%%.*} -ge 10 ]] && sup=yes || sup=no ;;
  rocky|rhel|almalinux|centos) [[ ${VERSION_ID%%.*} -ge 7 ]] && sup=yes || sup=no ;;
  *) sup=check ;;
esac
code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "https://$host:$port/" || true)
[[ $code != 000 ]] && net=yes || net=no
result=PASS; [[ $sup == yes && $net == yes ]] || result=FAIL
line="$(hostname -s) | $os | VEN-supported: $sup | 443 to PCE: $net | $result"
echo "$line"
echo "$line" > /root/preflight.txt
