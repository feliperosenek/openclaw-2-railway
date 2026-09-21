#!/bin/sh
set -eu

STATE_DIR="${OPENCLAW_STATE_DIR:-/data/.openclaw}"
WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-/data/workspace}"
CONFIG_PATH="${OPENCLAW_CONFIG_PATH:-${STATE_DIR}/openclaw.json}"
PORT="${PORT:-${OPENCLAW_GATEWAY_PORT:-8080}}"
BIND="${OPENCLAW_GATEWAY_BIND:-lan}"

mkdir -p "$STATE_DIR" "$WORKSPACE_DIR"

if [ "$(id -u)" = "0" ]; then
  chown -R node:node /data 2>/dev/null || true
fi

export OPENCLAW_GATEWAY_PORT="$PORT"
export OPENCLAW_STATE_DIR="$STATE_DIR"
export OPENCLAW_CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$STATE_DIR}"
export OPENCLAW_CONFIG_PATH="$CONFIG_PATH"
export OPENCLAW_WORKSPACE_DIR="$WORKSPACE_DIR"
export HOME="${HOME:-/data}"
export OPENCLAW_HOME="${OPENCLAW_HOME:-/data}"

# Ensure a valid OpenClaw 2.0 gateway config (mode=local required).
ORIGIN=""
if [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  ORIGIN="https://${RAILWAY_PUBLIC_DOMAIN}"
fi
export ORIGIN CONFIG_PATH
node <<'NODE'
const fs = require("fs");
const path = require("path");
const configPath = process.env.CONFIG_PATH;
const origin = process.env.ORIGIN || "";
let cfg = {};
try {
  cfg = JSON.parse(fs.readFileSync(configPath, "utf8"));
} catch {
  cfg = {};
}
cfg.gateway = cfg.gateway || {};
cfg.gateway.mode = cfg.gateway.mode || "local";
cfg.gateway.bind = cfg.gateway.bind || "lan";
// Railway edge proxy uses CGNAT 100.64.0.0/10 (see OpenClaw + Railway docs).
const proxies = new Set(cfg.gateway.trustedProxies || []);
proxies.add("100.64.0.0/10");
cfg.gateway.trustedProxies = [...proxies];
cfg.gateway.controlUi = cfg.gateway.controlUi || {};
if (origin) {
  const origins = new Set(cfg.gateway.controlUi.allowedOrigins || []);
  origins.add(origin);
  cfg.gateway.controlUi.allowedOrigins = [...origins];
}
if (!cfg.gateway.auth) {
  cfg.gateway.auth = { mode: "token" };
}
fs.mkdirSync(path.dirname(configPath), { recursive: true });
fs.writeFileSync(configPath, JSON.stringify(cfg, null, 2));
NODE

if [ "$(id -u)" = "0" ]; then
  chown -R node:node /data 2>/dev/null || true
fi

if [ "$(id -u)" = "0" ] && command -v runuser >/dev/null 2>&1; then
  exec runuser -u node -- env \
    HOME="$HOME" \
    OPENCLAW_HOME="$OPENCLAW_HOME" \
    OPENCLAW_STATE_DIR="$OPENCLAW_STATE_DIR" \
    OPENCLAW_CONFIG_DIR="$OPENCLAW_CONFIG_DIR" \
    OPENCLAW_CONFIG_PATH="$OPENCLAW_CONFIG_PATH" \
    OPENCLAW_WORKSPACE_DIR="$OPENCLAW_WORKSPACE_DIR" \
    OPENCLAW_GATEWAY_PORT="$OPENCLAW_GATEWAY_PORT" \
    OPENCLAW_GATEWAY_TOKEN="${OPENCLAW_GATEWAY_TOKEN:-}" \
    node openclaw.mjs gateway --bind "$BIND" --port "$PORT"
fi

exec node openclaw.mjs gateway --bind "$BIND" --port "$PORT"
