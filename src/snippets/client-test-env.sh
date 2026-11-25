# --- test-only: write /root/.pce/env from the PCE_TEST_* secrets if it is missing ---
if [[ ! -s /root/.pce/env && -n ${PCE_TEST_FQDN:-} ]]; then
  mkdir -p /root/.pce && chmod 700 /root/.pce
  printf 'PCE_FQDN=%s\nPCE_PORT=%s\nPCE_ORG=%s\nPCE_KEY=%s\nPCE_SECRET=%s\n' \
    "$PCE_TEST_FQDN" "${PCE_TEST_PORT:-443}" "$PCE_TEST_ORG" "$PCE_TEST_KEY" "$PCE_TEST_SECRET" > /root/.pce/env
  chmod 600 /root/.pce/env
fi
# --- end test-only ---
