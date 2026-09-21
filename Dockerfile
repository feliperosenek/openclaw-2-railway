# OpenClaw 2.0 for Railway — official image, pinned release
# OpenClaw 2.0 = v2026.8.1+; current pin: 2026.9.5
# https://github.com/openclaw/openclaw
# https://docs.openclaw.ai/install/railway

ARG OPENCLAW_VERSION=2026.9.5
FROM openclaw/openclaw:${OPENCLAW_VERSION}

USER root

WORKDIR /app
COPY entrypoint.sh /app/railway-entrypoint.sh
RUN chmod +x /app/railway-entrypoint.sh \
 && mkdir -p /data/.openclaw /data/workspace \
 && chown -R node:node /data /app/railway-entrypoint.sh \
 && ls -la /app/railway-entrypoint.sh \
 && head -1 /app/railway-entrypoint.sh

ENV HOME=/data \
    OPENCLAW_HOME=/data \
    OPENCLAW_STATE_DIR=/data/.openclaw \
    OPENCLAW_CONFIG_DIR=/data/.openclaw \
    OPENCLAW_CONFIG_PATH=/data/.openclaw/openclaw.json \
    OPENCLAW_WORKSPACE_DIR=/data/workspace \
    OPENCLAW_GATEWAY_PORT=8080 \
    OPENCLAW_GATEWAY_BIND=lan

EXPOSE 8080

# Invoke via /bin/sh so missing +x or shebang quirks cannot break boot.
ENTRYPOINT ["tini", "-s", "--", "/bin/sh", "/app/railway-entrypoint.sh"]
