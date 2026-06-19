#!/usr/bin/env bash
set -euo pipefail

LOG=/var/log/clamav/scan-home.log

QUARANTINE=/var/quarantine/clamav

echo "--- Scan started $(date) ---" >> "$LOG"
/usr/bin/clamscan --recursive --no-summary --move="$QUARANTINE" \
    --exclude-dir='/.git$' \
    --exclude-dir='/node_modules$' \
    --exclude-dir='/.nvm$' \
    --exclude-dir='/.npm$' \
    --exclude-dir='/.cache$' \
    --exclude-dir='/.nuget$' \
    --exclude-dir='/.dotnet$' \
    --exclude-dir='/.vscode$' \
    --exclude-dir='/.var$' \
    --exclude-dir='/.local/share/flatpak$' \
    --exclude-dir='/.local/share/containers$' \
    --exclude-dir='/.ServiceHub$' \
    --exclude-dir='/Mesen$' \
    --exclude-dir='/.claude$' \
    /home >> "$LOG" 2>&1
