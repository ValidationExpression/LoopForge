#!/usr/bin/env bash
# One-time / upgrade helper for a LoopForge host with outbound proxy + bundled cursor-agent.
set -euo pipefail
cd "$(dirname "$0")/../.."
APP_ROOT="$(pwd)"
source .env

PROXY_DIR="${LOOPFORGE_DATA_DIR}/proxy"
CURSOR_DIR="${LOOPFORGE_DATA_DIR}/cursor-agent"
mkdir -p "$PROXY_DIR" "$CURSOR_DIR"

if ! systemctl --user is-active loopforge-mihomo.service >/dev/null 2>&1; then
  echo "Start mihomo first: systemd user unit loopforge-mihomo.service" >&2
  exit 1
fi

grep -q '^HTTP_PROXY=' .env || printf '\nHTTP_PROXY=http://172.18.0.1:7890\nHTTPS_PROXY=http://172.18.0.1:7890\nNO_PROXY=localhost,127.0.0.1,192.168.44.0/24,10.0.0.0/8,mysql,platform\n' >> .env
sed -i 's|^HTTP_PROXY=.*|HTTP_PROXY=http://172.18.0.1:7890|;s|^HTTPS_PROXY=.*|HTTPS_PROXY=http://172.18.0.1:7890|' .env

COMPOSE_BASE="compose.yaml:compose.public-url.yaml:compose.outbound-proxy.yaml:compose.cursor-bundle.yaml"
if [[ -f compose.dev.yaml ]] && docker image inspect loopforge-platform:local >/dev/null 2>&1; then
  COMPOSE_BASE="compose.yaml:compose.dev.yaml:compose.public-url.yaml:compose.outbound-proxy.yaml:compose.cursor-bundle.yaml"
fi
python3 - <<'PY'
import pathlib, re, os
p = pathlib.Path(".env")
text = re.sub(r"(?m)^COMPOSE_FILE=.*\n?", "", p.read_text())
compose = os.environ.get("COMPOSE_FILE_SET", "")
if compose:
    p.write_text(text.rstrip("\n") + f"\nCOMPOSE_FILE={compose}\n")
PY
export COMPOSE_FILE_SET="$COMPOSE_BASE"

docker compose --profile platform up -d --no-build
echo "OK: proxy + cursor volume + platform"