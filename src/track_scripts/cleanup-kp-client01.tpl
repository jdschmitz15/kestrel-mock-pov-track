#!/bin/bash
# End of play: return the student's PCE org to empty, then tear down AWS (Instruqt also deletes
# the account; this is a backstop).
set -uxo pipefail
if [[ -f /root/.pce/env ]]; then
  org-reset --yes || echo "org-reset failed; run it by hand against this org"
fi
v() { local n="INSTRUQT_AWS_ACCOUNT_KESTREL_$1"; local l="INSTRUQT_AWS_ACCOUNT_kestrel_$1"; echo "${!n:-${!l:-}}"; }
export AWS_ACCESS_KEY_ID="$(v ADMIN_AWS_ACCESS_KEY_ID)" AWS_SECRET_ACCESS_KEY="$(v ADMIN_AWS_SECRET_ACCESS_KEY)"
cd /opt/kestrel/terraform && terraform destroy -input=false -auto-approve \
  -var "region=$(cat /opt/kestrel/aws-region)" || true
