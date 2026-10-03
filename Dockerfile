FROM nginx:1.28-alpine

RUN apk add --no-cache ca-certificates \
    && rm -f /etc/nginx/conf.d/default.conf

COPY nginx/relay.conf.template /etc/nginx/templates/relay.conf.template
COPY nginx/40-allowlist.sh /docker-entrypoint.d/40-allowlist.sh
RUN chmod +x /docker-entrypoint.d/40-allowlist.sh

# Only these env vars are substituted into the template (keeps nginx $vars intact).
ENV NGINX_ENVSUBST_FILTER="^RELAY_" \
    RELAY_ALLOWED_IPS="" \
    RELAY_ALLOWED_METHODS="[A-Za-z]+" \
    RELAY_ALLOW_FILES="true" \
    RELAY_MAX_BODY_SIZE="50m" \
    RELAY_READ_TIMEOUT="60s" \
    RELAY_TRUSTED_PROXIES="10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget -qO- http://127.0.0.1/healthz || exit 1
