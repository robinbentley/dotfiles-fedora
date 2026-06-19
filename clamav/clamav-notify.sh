#!/usr/bin/env bash
set -euo pipefail

PRIMARY_UID=$(loginctl list-sessions --no-legend 2>/dev/null \
    | awk '{print $3}' \
    | xargs -I{} id -u {} 2>/dev/null \
    | sort -n \
    | awk '$1 >= 1000 {print; exit}')

[ -z "$PRIMARY_UID" ] && exit 0

DBUS_SOCKET="/run/user/$PRIMARY_UID/bus"
[ ! -S "$DBUS_SOCKET" ] && exit 0

PRIMARY_USER=$(id -un "$PRIMARY_UID")
LOG=/var/log/clamav/scan-home.log

SESSION_ENV="XDG_RUNTIME_DIR=/run/user/$PRIMARY_UID DBUS_SESSION_BUS_ADDRESS=unix:path=$DBUS_SOCKET WAYLAND_DISPLAY=wayland-0"

ACTION=$(runuser -u "$PRIMARY_USER" -- \
    env $SESSION_ENV \
    /usr/bin/notify-send \
    --wait \
    --action="View Log" \
    --urgency=critical \
    --icon=security-high \
    "ClamAV Alert" \
    "Infected files found or scan error — check $LOG, quarantine: /var/quarantine/clamav" \
    || true)

if [ "$ACTION" = "View Log" ]; then
    runuser -u "$PRIMARY_USER" -- \
        env $SESSION_ENV \
        /usr/bin/xdg-open "$LOG"
fi
