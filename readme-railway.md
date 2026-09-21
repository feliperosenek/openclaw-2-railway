# Deploy and Host OpenClaw 2.0 on Railway

Deploy this repository as **OpenClaw 2.0** on Railway — the personal AI assistant that connects to WhatsApp, Telegram, Slack, Discord, and 20+ channels. OpenClaw 2.0 is the `v2026.8.1+` release line (guided setup, rebuilt Control UI, one trust boundary per gateway). This template pins the official Docker image so you stay on a current 2.0 build.

## About Hosting

This template runs the official [`openclaw/openclaw`](https://hub.docker.com/r/openclaw/openclaw) image (default tag **`2026.9.5`**) with Railway-ready defaults: gateway on port **8080**, state under `/data/.openclaw`, workspace under `/data/workspace`, and auth via `OPENCLAW_GATEWAY_TOKEN`.

After deploy, open `https://<your-domain>/openclaw` and paste the gateway token to access the Control UI. Configure your LLM provider and messaging channels from the browser — no SSH required for day-to-day use.

**Security:** the Gateway is exposed publicly. Read the [OpenClaw security docs](https://docs.openclaw.ai/gateway/security) and treat `OPENCLAW_GATEWAY_TOKEN` as an admin secret.

## Why Deploy

- **OpenClaw 2.0 ready** — pinned to a post-`v2026.8.1` release, not a stale 1.x / March pin
- **Official image** — thin Railway wrapper; upgrade by bumping `OPENCLAW_VERSION`
- **Persistent memory** — volume-backed config, SQLite auth stores, sessions, and workspace
- **Multi-channel** — Telegram, Discord, Slack, WhatsApp, and more via Control UI or `openclaw onboard`

## Common Use Cases

- Always-on personal AI assistant on Telegram / WhatsApp
- Team bot on Slack or Discord with persistent memory
- Self-hosted alternative to ChatGPT with your own API keys

## Dependencies for

This template provides the **OpenClaw Gateway + Control UI**. Your LLM provider API key and optional channel bot tokens are configured after deploy.

### Deployment Dependencies

- **OPENCLAW_GATEWAY_TOKEN** (required) — Shared secret for Gateway / Control UI. Use `${{secret(32)}}` in the template.
- **OPENCLAW_GATEWAY_PORT** — Must be `8080` and match Railway HTTP public networking.
- **Volume** — Mount at **`/data`** so index/config/sessions survive redeploys.
- **Public HTTP** — Enable Railway HTTP Proxy / domain on port **8080**.
- **Trusted proxy** — Template sets `gateway.trustedProxies` to `100.64.0.0/10` (Railway edge) and injects `RAILWAY_PUBLIC_DOMAIN` into Control UI `allowedOrigins`.

### Connecting

| Item | Value |
|------|-------|
| Control UI | `https://<domain>/openclaw` |
| Gateway token | `${{openclaw.OPENCLAW_GATEWAY_TOKEN}}` |
| State dir | `/data/.openclaw` |
| Workspace | `/data/workspace` |

**Smoke test (Railway shell):**

```
openclaw doctor --json
```

See [OpenClaw Railway docs](https://docs.openclaw.ai/install/railway) and [PROTOCOL / gateway docs](https://docs.openclaw.ai/gateway).

## Limitations

- Public Gateway exposure requires a strong token and channel allowlists.
- LLM inference cost is billed by your provider (OpenAI, Anthropic, OpenRouter, etc.), not Railway.
- Browser / sandbox tools may need more RAM than Hobby defaults.
- Upgrading major OpenClaw releases may require `openclaw doctor --fix` after bumping the image tag.

## Version

Built from `openclaw/openclaw` (default tag `2026.9.5` = OpenClaw 2.0 line; overridable via `OPENCLAW_VERSION` build arg).
