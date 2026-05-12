#!/bin/sh
set -eu

log() {
  echo "[firewall-defaults] $*"
}

if ! command -v uci >/dev/null 2>&1; then
  log "uci not found, skip"
  exit 1
fi

changed=0

current_forward="$(uci -q get firewall.@defaults[0].forward || true)"
if [ "$current_forward" != "ACCEPT" ]; then
  uci set firewall.@defaults[0].forward='ACCEPT'
  changed=1
  log "set firewall.@defaults[0].forward=ACCEPT"
else
  log "forward already ACCEPT"
fi

zone_count="$(uci -q show firewall | grep -c "=zone" || true)"
if [ "$zone_count" -gt 0 ]; then
  idx=0
  while :; do
    zone_name="$(uci -q get firewall.@zone[$idx].name || true)"
    [ -n "$zone_name" ] || break
    current_masq="$(uci -q get firewall.@zone[$idx].masq || true)"
    if [ "$current_masq" != "1" ]; then
      uci set firewall.@zone[$idx].masq='1'
      changed=1
      log "set firewall.@zone[$idx]($zone_name).masq=1"
    else
      log "zone $zone_name masq already enabled"
    fi
    idx=$((idx + 1))
  done
else
  log "no firewall zones found"
fi

if [ "$changed" -eq 1 ]; then
  uci commit firewall
  log "committed firewall changes"
else
  log "no firewall changes needed"
fi
