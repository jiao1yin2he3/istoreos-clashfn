#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-up}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.feiniu.yml}"
WORKDIR="${WORKDIR:-$(cd "$(dirname "$0")/.." && pwd)}"

cd "$WORKDIR"

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(docker-compose)
else
  echo "[compose] neither 'docker compose' nor 'docker-compose' is available"
  exit 1
fi

echo "[compose] workdir: $WORKDIR"
echo "[compose] file: $COMPOSE_FILE"
echo "[compose] action: $ACTION"
echo "[compose] command: ${COMPOSE_CMD[*]}"

case "$ACTION" in
  up)
    "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" up -d
    ;;
  down)
    "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" down
    ;;
  restart)
    "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" down
    "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" up -d
    ;;
  logs)
    "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" logs -f
    ;;
  ps)
    "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" ps
    ;;
  pull)
    "${COMPOSE_CMD[@]}" -f "$COMPOSE_FILE" pull
    ;;
  *)
    echo "Usage: $0 [up|down|restart|logs|ps|pull]"
    exit 1
    ;;
esac
