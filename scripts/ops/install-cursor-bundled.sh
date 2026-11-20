#!/usr/bin/env bash
# Link cursor-agent from the read-only LOOPFORGE_DATA_DIR/cursor-agent volume.
set -euo pipefail
REAL=/opt/loopforge/cursor-cli/.local/share/cursor-agent/versions/2026.11.19-f005e9d/cursor-agent
docker exec -u root loopforge-platform-1 test -x "$REAL" || exit 0
docker exec -u root loopforge-platform-1 ln -sf "$REAL" /usr/local/bin/cursor-agent