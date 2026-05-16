#!/usr/bin/env bash
set -e

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
    gnome-tweaks \
    dotnet-sdk-8.0 \
    code \
    microsoft-edge-stable

# =====================================================
# DBeaver Community
# =====================================================
sudo dnf install -y https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm

# =====================================================
# Flatpak — ensure Flathub remote is configured
# =====================================================
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# =====================================================
# Spotify via Flatpak
# =====================================================
flatpak list --app | grep -q com.spotify.Client \
    || flatpak install -y flathub com.spotify.Client

# =====================================================
# Slack via Flatpak
# =====================================================
flatpak list --app | grep -q com.slack.Slack \
    || flatpak install -y flathub com.slack.Slack

# =====================================================
# Starship prompt
# =====================================================
curl -sS https://starship.rs/install.sh | sh -s -- --yes
