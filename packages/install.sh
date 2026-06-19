#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

# =====================================================
# RPM Fusion (required for VLC and media codecs)
# =====================================================
sudo dnf install -y \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

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

sudo touch /etc/containers/nodocker

# =====================================================
# VLC and media codecs (--allowerasing replaces Fedora's
# libswscale-free with the RPM Fusion ffmpeg-libs build)
# =====================================================
sudo dnf install -y --allowerasing \
    vlc \
    vlc-plugin-fluidsynth \
    ffmpeg-libs \
    x265 \
    gstreamer1-plugin-libav

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
# Bruno — API client (no official DNF repo)
# =====================================================
BRUNO_RPM_URL=$(curl -fsSL https://api.github.com/repos/usebruno/bruno/releases/latest \
    | grep -oP '"browser_download_url":\s*"\K[^"]+x86_64_linux\.rpm')
sudo dnf install -y "$BRUNO_RPM_URL"

# =====================================================
# ClamAV — antivirus with daily /home scan
# =====================================================
sudo dnf install -y clamav clamav-update clamd

# Remove the 'Example' placeholder that prevents both configs from loading,
# and uncomment the LocalSocket line that clamd requires to start
sudo sed -i '/^Example$/d' /etc/freshclam.conf
sudo sed -i '/^Example$/d' /etc/clamd.d/scan.conf
sudo sed -i 's|^#LocalSocket |LocalSocket |' /etc/clamd.d/scan.conf

# Keep virus definitions current
sudo systemctl enable --now clamav-freshclam.service

# Start the scanning daemon
sudo systemctl enable --now clamd@scan.service

# Install and enable the nightly /home scan (runs at 02:00, boots catch up via Persistent=true)
sudo install -m 644 "$DOTFILES_DIR/clamav/clamav-scan-home.service" /etc/systemd/system/
sudo install -m 644 "$DOTFILES_DIR/clamav/clamav-scan-home.timer"   /etc/systemd/system/
sudo install -m 644 "$DOTFILES_DIR/clamav/clamav-notify.service"    /etc/systemd/system/
sudo install -m 755 "$DOTFILES_DIR/clamav/clamav-scan-home.sh"      /usr/local/bin/
sudo install -m 755 "$DOTFILES_DIR/clamav/clamav-notify.sh"         /usr/local/bin/
sudo install -d -m 1777 /var/quarantine/clamav
sudo systemctl daemon-reload
sudo systemctl enable --now clamav-scan-home.timer

# =====================================================
# Starship prompt
# =====================================================
STARSHIP_INSTALL=$(mktemp)
curl -fsSL "https://starship.rs/install.sh" -o "$STARSHIP_INSTALL"
sh "$STARSHIP_INSTALL" --yes
rm -f "$STARSHIP_INSTALL"
