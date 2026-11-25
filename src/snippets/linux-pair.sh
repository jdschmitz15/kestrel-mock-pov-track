# --- test-only VEN pairing, used by solve scripts. Needs the PCE_TEST_* secrets. ---
pce_test_ready() { [[ -n ${PCE_TEST_FQDN:-} && -n ${PCE_TEST_ORG:-} && -n ${PCE_TEST_KEY:-} && -n ${PCE_TEST_SECRET:-} ]]; }
pce_test_pair_cmd() {
  # Prints a one-line pairing command for Linux using a fresh activation code.
  local port=${PCE_TEST_PORT:-443} base auth prof code
  base="https://$PCE_TEST_FQDN:$port/api/v2"; auth="$PCE_TEST_KEY:$PCE_TEST_SECRET"
  prof=$(curl -fsS -u "$auth" "$base/orgs/$PCE_TEST_ORG/pairing_profiles?name=Kestrel-POV" \
         | python3 -c 'import json,sys; print(json.load(sys.stdin)[0]["href"])')
  code=$(curl -fsS -u "$auth" -H 'Content-Type: application/json' -X POST -d '{}' "$base$prof/pairing_key" \
         | python3 -c 'import json,sys; print(json.load(sys.stdin)["activation_code"])')
  echo "rm -rf /opt/illumio_ven_data/tmp && umask 026 && mkdir -p /opt/illumio_ven_data/tmp && curl -fsS --tlsv1.2 'https://$PCE_TEST_FQDN:$port/api/v25/software/ven/image?pair_script=pair.sh&profile_id=${prof##*/}' -o /opt/illumio_ven_data/tmp/pair.sh && chmod +x /opt/illumio_ven_data/tmp/pair.sh && /opt/illumio_ven_data/tmp/pair.sh --management-server $PCE_TEST_FQDN:$port --activation-code $code"
}
pce_test_pair_here() {
  pce_test_ready || { echo "PCE_TEST_* secrets not set; skipping VEN pairing"; return 0; }
  [[ -x /opt/illumio_ven/illumio-ven-ctl ]] && { echo "VEN already installed"; return 0; }
  bash -c "$(pce_test_pair_cmd)"
}
# --- end test-only pairing ---
