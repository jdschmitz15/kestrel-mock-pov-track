#!/bin/bash
# NEN host (no VEN). Installs the NEN RPM but does not activate it: the student pairs it to
# their own SaaS PCE org in challenge 4.
#   NEN_RPM_URL        where to download the RPM. For a GitHub release asset in a private repo use
#                      https://api.github.com/repos/<owner>/<repo>/releases/assets/<asset-id>
#   NEN_GITHUB_TOKEN   read-only GitHub token for that private repo (leave empty for a public URL)
set -euo pipefail
dnf install -y curl
if [[ -z "${NEN_RPM_URL:-}" || "${NEN_RPM_URL}" == none ]]; then
  echo "NEN_RPM_URL secret is not set; the NEN must be installed by hand." >&2
  exit 0
fi
args=(-fsSL --retry 3 -o /tmp/illumio-nen.rpm)
if [[ -n "${NEN_GITHUB_TOKEN:-}" && "${NEN_GITHUB_TOKEN}" != none ]]; then
  args+=(-H "Authorization: Bearer $NEN_GITHUB_TOKEN")
  # API asset URLs return JSON unless asked for the file itself
  [[ $NEN_RPM_URL == https://api.github.com/* ]] && args+=(-H "Accept: application/octet-stream")
fi
curl "${args[@]}" "$NEN_RPM_URL"
set -x
rpm -qip /tmp/illumio-nen.rpm   # fails early if we downloaded an error page instead of an RPM
dnf install -y /tmp/illumio-nen.rpm
# Open the IPFIX collection port the student will configure in challenge 4.
if systemctl is-active --quiet firewalld; then
  firewall-cmd --permanent --add-port=4739/udp && firewall-cmd --reload
fi
