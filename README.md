# OpenClaw 2.0 for Railway

Self-hosted [OpenClaw](https://openclaw.ai) **2.0** on [Railway](https://railway.com). Personal AI assistant with Gateway + Control UI over HTTP (port **8080**).

Pinned to the official image: **`openclaw/openclaw:2026.9.5`** (OpenClaw 2.0 = release line `v2026.8.1+`).

---

## What is OpenClaw?

OpenClaw is an open-source personal AI assistant that connects to chat apps you already use — Telegram, Discord, Slack, WhatsApp, and more. You configure an LLM provider, then talk to your agent from those channels.

- **Gateway** — always-on control plane for agents, channels, tools, and sessions
- **Control UI** — browser UI at the domain root for setup and operator access
- **Persistent state** — config, auth, sessions, and workspace on a Railway volume

Security-sensitive: the Gateway is exposed publicly. Read the [OpenClaw security docs](https://docs.openclaw.ai/gateway/security) before production use.

---

## Deploy on Railway

### 1. Create service

Deploy this repo from GitHub (root directory = repository root).

### 2. Variables

| Variable | Value |
|----------|-------|
| `OPENCLAW_GATEWAY_TOKEN` | `${{secret(32)}}` |
| `OPENCLAW_GATEWAY_PORT` | `8080` |
| `OPENCLAW_STATE_DIR` | `/data/.openclaw` |
| `OPENCLAW_WORKSPACE_DIR` | `/data/workspace` |

Optional: `OPENCLAW_CONFIG_DIR=/data/.openclaw`, `OPENCLAW_CONFIG_PATH=/data/.openclaw/openclaw.json`, `OPENCLAW_GATEWAY_BIND=lan`.

### 3. Volume

Attach a volume mounted at:

```
/data
```

OpenClaw stores config, SQLite auth, sessions, and workspace under this path.

### 4. Networking

Enable **HTTP Proxy** / public domain on port **8080**.

Open:

```
https://<your-domain>/
```

Paste `OPENCLAW_GATEWAY_TOKEN` when the Control UI asks for the Gateway secret. On first browser connect you may need one-time device pairing:

```bash
railway ssh -s <service> -- openclaw devices list
railway ssh -s <service> -- openclaw devices approve <request-id>
```

### 5. Verify

```bash
railway ssh -s <service> -- openclaw doctor --json
```

Control UI HTML should load at `/` (HTTP 200). Liveness probe is `GET /healthz` (HTTP 200). Gateway logs should show `[gateway] ready`.

---

## Railway-specific bootstrap

The entrypoint:

- Ensures `gateway.mode=local` and token auth
- Trusts Railway’s edge proxy (`100.64.0.0/10`) via `gateway.trustedProxies`
- Injects `https://${RAILWAY_PUBLIC_DOMAIN}` into Control UI `allowedOrigins`

---

## Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Extends official `openclaw/openclaw` with Railway entrypoint |
| `entrypoint.sh` | Volume dirs, config bootstrap, start gateway on `$PORT` / 8080 |
| `railway.json` | Dockerfile builder, restart on failure |
| `.env.example` | Required variables |
| `readme-railway.md` | Marketplace description |

---

## Build args

| Arg | Default | Description |
|-----|---------|-------------|
| `OPENCLAW_VERSION` | `2026.9.5` | Docker tag for `openclaw/openclaw` |

---

## References

- [OpenClaw](https://openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Railway install docs](https://docs.openclaw.ai/install/railway)
- [OpenClaw 2.0 release (`v2026.8.1`)](https://docs.openclaw.ai/releases/2026.8.1)
- [Security](https://docs.openclaw.ai/gateway/security)
