#!/bin/sh
# ─────────────────────────────────────────────────────────────
# n8n startup script
#   1. Injects BOT_TOKEN into credentials template
#   2. Starts n8n in background
#   3. Waits for n8n to be healthy
#   4. Imports credentials + workflows (idempotent – same IDs)
#   5. Activates all workflows
#   6. Brings n8n to foreground
# ─────────────────────────────────────────────────────────────
set -e

IMPORT_DIR="/data/import-workflows"
CRED_TEMPLATE="/data/import-workflows/credentials.json"
CRED_READY="/tmp/credentials_ready.json"

# ── 1. Render credentials from env ───────────────────────────
if [ -f "$CRED_TEMPLATE" ] && [ -n "$BOT_TOKEN" ]; then
  sed "s|\${BOT_TOKEN}|${BOT_TOKEN}|g" "$CRED_TEMPLATE" > "$CRED_READY"
  echo "[n8n-init] Credentials rendered."
fi

# ── 2. Start n8n in background ────────────────────────────────
n8n &
N8N_PID=$!

# ── 3. Wait for health endpoint ──────────────────────────────
echo "[n8n-init] Waiting for n8n to be ready..."
until wget -qO- http://localhost:5678/healthz > /dev/null 2>&1; do
  sleep 3
done
echo "[n8n-init] n8n is up!"

# ── 4. Import credentials ────────────────────────────────────
if [ -f "$CRED_READY" ]; then
  n8n import:credentials --input="$CRED_READY" && \
    echo "[n8n-init] Credentials imported." || \
    echo "[n8n-init] Credential import failed (may already exist)."
fi

# ── 5. Import workflows ──────────────────────────────────────
if [ -d "$IMPORT_DIR" ]; then
  for f in "$IMPORT_DIR"/*.json; do
    # skip credentials file
    case "$f" in
      *credentials*) continue ;;
    esac
    if [ -f "$f" ]; then
      n8n import:workflow --input="$f" && \
        echo "[n8n-init] Imported: $f" || \
        echo "[n8n-init] Import failed for: $f"
    fi
  done
fi

# ── 6. Activate all imported workflows ───────────────────────
n8n update:workflow --all --active=true && \
  echo "[n8n-init] All workflows activated." || \
  echo "[n8n-init] Activation step failed (non-fatal)."

# ── 7. Keep n8n in foreground ────────────────────────────────
wait $N8N_PID
