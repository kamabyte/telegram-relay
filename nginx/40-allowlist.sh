#!/bin/sh
# Renders comma/space separated RELAY_ALLOWED_IPS and RELAY_TRUSTED_PROXIES into nginx includes.
set -eu

out=/etc/nginx/relay
mkdir -p "$out"

# Prints "<prefix><item><suffix>;" for each item of a comma/space separated list.
render() {
    echo "$3" | tr ', ' '\n\n' | while read -r item; do
        if [ -n "$item" ]; then echo "$1$item$2;"; fi
    done
}

if [ -z "${RELAY_ALLOWED_IPS:-}" ]; then
    echo "$0: RELAY_ALLOWED_IPS is empty, relay will deny everyone (use 0.0.0.0/0,::/0 to allow all)" >&2
fi

render "" " 1" "${RELAY_ALLOWED_IPS:-}" > "$out/allowlist.conf"
render "set_real_ip_from " "" "${RELAY_TRUSTED_PROXIES:-}" > "$out/trusted-proxies.conf"

echo "$0: allowlist: $(grep -c ' 1;$' "$out/allowlist.conf" || true) address(es)"
