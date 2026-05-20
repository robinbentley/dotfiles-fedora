#!/usr/bin/env bash
set -euo pipefail

# =====================================================
# Microsoft repo GPG key (shared by VSCode and Edge)
# =====================================================
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

# =====================================================
# VSCode
# =====================================================
cat << 'EOF' | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# =====================================================
# Microsoft Edge (for Teams and Outlook PWAs)
# =====================================================
cat << 'EOF' | sudo tee /etc/yum.repos.d/microsoft-edge.repo > /dev/null
[microsoft-edge]
name=Microsoft Edge
baseurl=https://packages.microsoft.com/yumrepos/edge
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

sudo dnf makecache --refresh

# =====================================================
# DNF packages
# =====================================================
sudo dnf install -y \
    zsh \
    kitty \
    vim \
    tree \
    unzip \
    gh \
    bat \
    gnome-tweaks \
    dotnet-sdk-8.0 \
    podman-docker \
    podman-compose \
    code \
    microsoft-edge-stable \
    easyeffects \
    dbeaver-ce \
    htop \
    pavucontrol \
    session-manager-plugin

# =====================================================
# Flatpak — ensure Flathub remote is configured
# =====================================================
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

FLATPAKS=(
    com.bitwarden.desktop
    com.slack.Slack
    com.spotify.Client
)

for app in "${FLATPAKS[@]}"; do
    flatpak list --app --columns=application | grep -qx "$app" \
        || flatpak install -y flathub "$app"
done

# =====================================================
# Starship prompt
# =====================================================
STARSHIP_INSTALL=$(mktemp)
curl -fsSL "https://starship.rs/install.sh" -o "$STARSHIP_INSTALL"
sh "$STARSHIP_INSTALL" --yes
rm -f "$STARSHIP_INSTALL"
