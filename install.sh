#!/usr/bin/env bash
set -e

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
ln -sf "$DOTFILES/zshrc"                  "$HOME/.zshrc"
ln -sf "$DOTFILES/vim/vimrc"              "$HOME/.vimrc"
ln -sf "$DOTFILES/dots/gitconfig"         "$HOME/.gitconfig"
ln -sf "$DOTFILES/dots/gitignore.global"  "$HOME/.gitignore.global"
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"
mkdir -p "$HOME/.config/kitty"
ln -sf "$DOTFILES/kitty/kitty.conf"       "$HOME/.config/kitty/kitty.conf"
mkdir -p "$HOME/.config/Code/User"
ln -sf "$DOTFILES/vscode/settings.json"   "$HOME/.config/Code/User/settings.json"

echo "==> Setting zsh as default shell"
sudo usermod -s "$(which zsh)" "$USER"

echo "==> Installing NVM"
NVM_VERSION=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)
if [ -z "$NVM_VERSION" ]; then
    echo "Error: could not determine latest NVM version — check your internet connection"
    exit 1
fi
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | PROFILE=/dev/null bash

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
    cd /tmp
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
    cd "$DOTFILES"
fi

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
    ssh-keygen -t ed25519 -C "robinbentley@me.com" -f "$HOME/.ssh/id_fed26uwu" -N ""
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
