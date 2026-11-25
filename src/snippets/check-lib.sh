# --- check helpers ---
fail() { if command -v fail-message >/dev/null 2>&1; then fail-message "$1"; fi; echo "FAIL: $1"; exit 1; }
need_pce() { [[ -s /root/.pce/env ]] || fail "No PCE details yet. Run pov-connect in the Client tab."; }
# --- end check helpers ---
