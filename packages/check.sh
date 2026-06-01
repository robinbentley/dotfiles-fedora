#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL="$SCRIPT_DIR/install.sh"
IGNORE="$SCRIPT_DIR/.check-ignore"

# Extract dnf packages from all multi-line install blocks (including --allowerasing variant)
DNF_SCRIPT=$(awk '/sudo dnf install -y( --allowerasing)? \\/,/^[[:space:]]*$/' "$INSTALL" \
    | grep -v 'sudo dnf install' \
    | sed 's/[[:space:]\\]//g' \
    | grep -v '^$' \
    | grep -v '^https://')

# Direct RPM installs (no official repo — installed via URL in install.sh)
DIRECT_RPMS="bruno"

ALL_SCRIPT_PKGS="$DNF_SCRIPT
$DIRECT_RPMS"

# Flatpak apps listed in install script (reads the FLATPAKS array)
FLATPAK_SCRIPT=$(awk '/^FLATPAKS=\(/,/^\)/' "$INSTALL" \
    | grep -oE '[a-zA-Z0-9]+\.[a-zA-Z0-9]+\.[a-zA-Z0-9]+')

echo "=== DNF: in script but not installed ==="
missing=0
while IFS= read -r pkg; do
    rpm -q --whatprovides "$pkg" &>/dev/null || { echo "  MISSING: $pkg"; missing=1; }
done <<< "$ALL_SCRIPT_PKGS"
[[ $missing -eq 0 ]] && echo "  (none)" || true

echo ""
echo "=== DNF: installed (user) but not in script ==="
extra=0
while IFS= read -r pkg; do
    # Treat vim-enhanced as covered by 'vim' in the script
    canonical="$pkg"
    [[ "$pkg" == "vim-enhanced" ]] && canonical="vim"
    echo "$ALL_SCRIPT_PKGS" | grep -qx "$canonical" || { echo "  EXTRA: $pkg"; extra=1; }
done < <(dnf repoquery --userinstalled --queryformat '%{name}\n' 2>/dev/null \
    | { [[ -f "$IGNORE" ]] && grep -vEf "$IGNORE" || cat; } \
    | sort)
[[ $extra -eq 0 ]] && echo "  (none)" || true

echo ""
echo "=== Flatpak: in script but not installed ==="
missing=0
while IFS= read -r app; do
    flatpak list --app --columns=application 2>/dev/null | grep -qx "$app" \
        || { echo "  MISSING: $app"; missing=1; }
done <<< "$FLATPAK_SCRIPT"
[[ $missing -eq 0 ]] && echo "  (none)" || true

echo ""
echo "=== Flatpak: installed but not in script ==="
extra=0
while IFS= read -r app; do
    echo "$FLATPAK_SCRIPT" | grep -qx "$app" || { echo "  EXTRA: $app"; extra=1; }
done < <(flatpak list --app --columns=application 2>/dev/null | sort)
[[ $extra -eq 0 ]] && echo "  (none)" || true
