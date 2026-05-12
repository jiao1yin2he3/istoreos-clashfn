#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-up}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.feiniu.yml}"
WORKDIR="${WORKDIR:-$(cd "$(dirname "$0")/.." && pwd)}"

cd "$WORKDIR"

echo "[compose] workdir: $WORKDIR"
echo "[compose] file: $COMPOSE_FILE"
echo "[compose] action: $ACTION"

case "$ACTION" in
  up)
    docker compose -f "$COMPOSE_FILE" up -d
    ;;
  down)
    docker compose -f "$COMPOSE_FILE" down
    ;;
  restart)
    docker compose -f "$COMPOSE_FILE" down
    docker compose -f "$COMPOSE_FILE" up -d
    ;;
  logs)
    docker compose -f "$COMPOSE_FILE" logs -f
    ;;
  ps)
    docker compose -f "$COMPOSE_FILE" ps
    ;;
  pull)
    docker compose -f "$COMPOSE_FILE" pull
    ;;
  *)
    echo "Usage: $0 [up|down|restart|logs|ps|pull]"
    exit 1
    ;;
esac
