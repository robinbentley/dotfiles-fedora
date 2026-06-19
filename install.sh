#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"

if [ ! -d "$DOTFILES" ]; then
    echo "Error: dotfiles directory not found at $DOTFILES"
    echo "Clone the repo there first: git clone <repo> $DOTFILES"
    exit 1
fi

echo "==> Installing packages"
bash "$DOTFILES/packages/install.sh"

echo "==> Installing fonts"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
cp "$DOTFILES/resources/fonts/adwaitamonoNF/"*.ttf "$FONT_DIR/"
fc-cache -f "$FONT_DIR"

echo "==> Symlinking dotfiles"
mkdir -p "$HOME/.local/bin"
ln -sf "$DOTFILES/clamav/avscan"          "$HOME/.local/bin/avscan"
ln -sf "$DOTFILES/scripts/heic2jpg"        "$HOME/.local/bin/heic2jpg"
ln -sf "$DOTFILES/zshrc"                  "$HOME/.zshrc"
ln -sf "$DOTFILES/vim/vimrc"              "$HOME/.vimrc"
ln -sf "$DOTFILES/dots/gitconfig"         "$HOME/.gitconfig"
ln -sf "$DOTFILES/dots/gitignore.global"  "$HOME/.gitignore.global"
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"
ln -sf "$DOTFILES/dots/xdg-terminals.list" "$HOME/.config/xdg-terminals.list"
mkdir -p "$HOME/.config/kitty"
ln -sf "$DOTFILES/kitty/kitty.conf"       "$HOME/.config/kitty/kitty.conf"
mkdir -p "$HOME/.config/Code/User"
ln -sf "$DOTFILES/vscode/settings.json"   "$HOME/.config/Code/User/settings.json"
mkdir -p "$HOME/.config/containers"
ln -sf "$DOTFILES/containers/containers.conf" "$HOME/.config/containers/containers.conf"
mkdir -p "$HOME/.config/autostart"
ln -sf "$DOTFILES/audio/audio-defaults.desktop" "$HOME/.config/autostart/audio-defaults.desktop"
mkdir -p "$HOME/.local/share/easyeffects/input"
ln -sf "$DOTFILES/audio/easyeffects/input/fedora-ugreen-usb.json" "$HOME/.local/share/easyeffects/input/fedora-ugreen-usb.json"

echo "==> Setting zsh as default shell"
sudo usermod -s "$(which zsh)" "$USER"

echo "==> Installing NVM"
NVM_VERSION=$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)
if [ -z "$NVM_VERSION" ]; then
    echo "Error: could not determine latest NVM version — check your internet connection"
    exit 1
fi
NVM_INSTALL=$(mktemp)
curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" -o "$NVM_INSTALL"
PROFILE=/dev/null bash "$NVM_INSTALL"
rm -f "$NVM_INSTALL"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "==> Installing Node.js LTS"
nvm install --lts
nvm alias default 'lts/*'

echo "==> Installing vim-plug and plugins"
bash "$DOTFILES/vim/install.sh"

echo "==> Installing AWS CLI"
if command -v aws &>/dev/null; then
    echo "AWS CLI already installed, skipping"
else
    AWSTMP=$(mktemp -d)
    trap 'rm -rf "$AWSTMP"' EXIT
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"     -o "$AWSTMP/awscliv2.zip"
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig" -o "$AWSTMP/awscliv2.zip.sig"
    # Import AWS CLI public key (key ID A6310ACC4672475C, expires 2026-07-07)
    # Source: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
    gpg --import << 'AWSKEY'
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBF2Cr7UBEADJZHcgusOJl7ENSyumXh85z0TRV0xJorM2B/JL0kHOyigQluUG
ZMLhENaG0bYatdrKP+3H91lvK050pXwnO/R7fB/FSTouki4ciIx5OuLlnJZIxSzx
PqGl0mkxImLNbGWoi6Lto0LYxqHN2iQtzlwTVmq9733zd3XfcXrZ3+LblHAgEt5G
TfNxEKJ8soPLyWmwDH6HWCnjZ/aIQRBTIQ05uVeEoYxSh6wOai7ss/KveoSNBbYz
gbdzoqI2Y8cgH2nbfgp3DSasaLZEdCSsIsK1u05CinE7k2qZ7KgKAUIcT/cR/grk
C6VwsnDU0OUCideXcQ8WeHutqvgZH1JgKDbznoIzeQHJD238GEu+eKhRHcz8/jeG
94zkcgJOz3KbZGYMiTh277Fvj9zzvZsbMBCedV1BTg3TqgvdX4bdkhf5cH+7NtWO
lrFj6UwAsGukBTAOxC0l/dnSmZhJ7Z1KmEWilro/gOrjtOxqRQutlIqG22TaqoPG
fYVN+en3Zwbt97kcgZDwqbuykNt64oZWc4XKCa3mprEGC3IbJTBFqglXmZ7l9ywG
EEUJYOlb2XrSuPWml39beWdKM8kzr1OjnlOm6+lpTRCBfo0wa9F8YZRhHPAkwKkX
XDeOGpWRj4ohOx0d2GWkyV5xyN14p2tQOCdOODmz80yUTgRpPVQUtOEhXQARAQAB
tCFBV1MgQ0xJIFRlYW0gPGF3cy1jbGlAYW1hem9uLmNvbT6JAlQEEwEIAD4CGwMF
CwkIBwIGFQoJCAsCBBYCAwECHgECF4AWIQT7Xbd/1cEYuAURraimMQrMRnJHXAUC
aGveYQUJDMpiLAAKCRCmMQrMRnJHXKBYD/9Ab0qQdGiO5hObchG8xh8Rpb4Mjyf6
0JrVo6m8GNjNj6BHkSc8fuTQJ/FaEhaQxj3pjZ3GXPrXjIIVChmICLlFuRXYzrXc
Pw0lniybypsZEVai5kO0tCNBCCFuMN9RsmmRG8mf7lC4FSTbUDmxG/QlYK+0IV/l
uJkzxWa+rySkdpm0JdqumjegNRgObdXHAQDWlubWQHWyZyIQ2B4U7AxqSpcdJp6I
S4Zds4wVLd1WE5pquYQ8vS2cNlDm4QNg8wTj58e3lKN47hXHMIb6CHxRnb947oJa
pg189LLPR5koh+EorNkA1wu5mAJtJvy5YMsppy2y/kIjp3lyY6AmPT1posgGk70Z
CmToEZ5rbd7ARExtlh76A0cabMDFlEHDIK8RNUOSRr7L64+KxOUegKBfQHb9dADY
qqiKqpCbKgvtWlds909Ms74JBgr2KwZCSY1HaOxnIr4CY43QRqAq5YHOay/mU+6w
hhmdF18vpyK0vfkvvGresWtSXbag7Hkt3XjaEw76BzxQH21EBDqU8WJVjHgU6ru+
DJTs+SxgJbaT3hb/vyjlw0lK+hFfhWKRwgOXH8vqducF95NRSUxtS4fpqxWVaw3Q
V2OWSjbne99A5EPEySzryFTKbMGwaTlAwMCwYevt4YT6eb7NmFhTx0Fis4TalUs+
j+c7Kg92pDx2uQ==
=OBAt
-----END PGP PUBLIC KEY BLOCK-----
AWSKEY
    gpg --verify "$AWSTMP/awscliv2.zip.sig" "$AWSTMP/awscliv2.zip"
    unzip -q "$AWSTMP/awscliv2.zip" -d "$AWSTMP"
    sudo "$AWSTMP/aws/install"
fi

echo "==> Installing AWS Session Manager plugin"
if ! command -v session-manager-plugin &>/dev/null; then
    sudo dnf install -y "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm"
else
    echo "AWS Session Manager plugin already installed, skipping"
fi

echo "==> Configuring systemd-oomd"
sudo cp "$DOTFILES/systemd/oomd.conf" /etc/systemd/oomd.conf
sudo systemctl restart systemd-oomd

echo "==> Configuring GNOME"
gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']" 2>/dev/null \
    || echo "Warning: could not remap Caps Lock — run manually after logging into GNOME"
gsettings set org.gnome.desktop.default-applications.terminal exec 'kitty' 2>/dev/null \
    || echo "Warning: could not set default terminal — run manually after logging into GNOME"
gsettings set org.gnome.desktop.default-applications.terminal exec-arg '' 2>/dev/null

echo "==> Generating SSH key"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/id_fed26uwu" ]; then
    ssh-keygen -t ed25519 -C "robinbentley@me.com" -f "$HOME/.ssh/id_fed26uwu"
    echo ""
    echo "SSH public key — add this to GitHub at https://github.com/settings/keys:"
    echo ""
    cat "$HOME/.ssh/id_fed26uwu.pub"
else
    echo "SSH key already exists, skipping"
fi

echo "==> Configuring SSH"
if ! grep -q "Host github.com" "$HOME/.ssh/config" 2>/dev/null; then
    cat >> "$HOME/.ssh/config" << 'EOF'

Host github.com
    IdentityFile ~/.ssh/id_fed26uwu
EOF
    chmod 600 "$HOME/.ssh/config"
fi

echo ""
echo "==> Done! Manual steps remaining:"
echo "  1. Add the SSH public key above to GitHub: https://github.com/settings/keys"
echo "  2. Log out and back in for the shell change to take effect"
echo "  3. Open Edge -> teams.microsoft.com -> sign in -> Settings -> Install this site as an app"
echo "  4. Open Edge -> outlook.office.com  -> sign in -> Settings -> Install this site as an app"
echo "  5. In VSCode: set font family to 'AdwaitaMono Nerd Font Mono' after Settings Sync runs"
