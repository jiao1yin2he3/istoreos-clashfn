#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-istoreos}"
OPENCLASH_PATH="${OPENCLASH_PATH:-/cgi-bin/luci/admin/services/openclash}"
LUCI_PATH="${LUCI_PATH:-/cgi-bin/luci}"

ok() { echo "[OK] $*"; }
warn() { echo "[WARN] $*"; }
fail() { echo "[FAIL] $*"; exit 1; }

if ! command -v docker >/dev/null 2>&1; then
  fail "docker command not found"
fi

if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  fail "container '$CONTAINER_NAME' is not running"
fi
ok "container '$CONTAINER_NAME' is running"

container_ip="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME" 2>/dev/null || true)"
if [ -n "$container_ip" ]; then
  ok "container IP: $container_ip"
else
  warn "could not detect container IP"
fi

forward_value="$(docker exec "$CONTAINER_NAME" sh -lc "uci -q get firewall.@defaults[0].forward || true" 2>/dev/null || true)"
if [ "$forward_value" = "ACCEPT" ]; then
  ok "firewall forward default is ACCEPT"
else
  fail "firewall forward default is '$forward_value' (expected ACCEPT)"
fi

masq_output="$(docker exec "$CONTAINER_NAME" sh -lc "uci show firewall | grep '\\.masq=' || true" 2>/dev/null || true)"
if echo "$masq_output" | grep -q "='1'"; then
  ok "firewall masquerading is enabled on at least one zone"
  echo "$masq_output"
else
  fail "no firewall zone with masq='1' found"
fi

if docker exec "$CONTAINER_NAME" sh -lc "ps | grep -q '[u]httpd'" 2>/dev/null; then
  ok "uhttpd process detected"
else
  fail "uhttpd process not detected"
fi

if docker exec "$CONTAINER_NAME" sh -lc "ps | grep -q '[r]pcd'" 2>/dev/null; then
  ok "rpcd process detected"
else
  warn "rpcd process not detected"
fi

if docker exec "$CONTAINER_NAME" sh -lc "test -d /usr/lib/lua/luci/controller/openclash -o -f /usr/share/rpcd/acl.d/luci-app-openclash.json -o -d /www/luci-static/resources/openclash" 2>/dev/null; then
  ok "OpenClash-related files detected"
else
  warn "OpenClash-related files not detected; verify package installation"
fi

if command -v curl >/dev/null 2>&1 && [ -n "$container_ip" ]; then
  luci_http="$(curl -k -L -s -o /dev/null -w '%{http_code}' "http://$container_ip$LUCI_PATH" || true)"
  if [ "$luci_http" = "200" ] || [ "$luci_http" = "302" ] || [ "$luci_http" = "401" ] || [ "$luci_http" = "403" ]; then
    ok "LuCI endpoint reachable: HTTP $luci_http"
  else
    warn "LuCI endpoint returned unexpected HTTP code: ${luci_http:-none}"
  fi

  openclash_http="$(curl -k -L -s -o /dev/null -w '%{http_code}' "http://$container_ip$OPENCLASH_PATH" || true)"
  if [ "$openclash_http" = "200" ] || [ "$openclash_http" = "302" ] || [ "$openclash_http" = "401" ] || [ "$openclash_http" = "403" ]; then
    ok "OpenClash endpoint reachable: HTTP $openclash_http"
  else
    warn "OpenClash endpoint returned unexpected HTTP code: ${openclash_http:-none}"
  fi
else
  warn "curl not available or container IP missing; skip HTTP checks"
fi

ok "runtime checks finished"
