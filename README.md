# Fedora Dotfiles

Year of the linux desktop? Fedora Workstation dev box so I can get off WSL on my big machine.

## Requirements

- Fresh Fedora Workstation install
- Git and Podman are pre-installed on Fedora — no action needed
- `sudo` access

## Install

```bash
git clone git@github.com:robinbentley/dotfiles-fedora.git ~/dotfiles
cd ~/dotfiles && bash install.sh
```

## What gets installed

**Packages**
- Zsh + Starship prompt
- Kitty terminal
- Vim
- VSCode (Microsoft RPM repo)
- Microsoft Edge (for Teams and Outlook PWAs)
- DBeaver Community
- GNOME Tweaks
- .NET SDK 8.0

**Via Flatpak**
- Spotify
- Slack

**Via install scripts**
- NVM + Node.js LTS
- AWS CLI

## Post-install manual steps

1. Add the SSH public key printed at the end of install to GitHub: https://github.com/settings/keys
2. Log out and back in for the shell change to take effect
3. Open Edge → `teams.microsoft.com` → sign in → Settings → Install this site as an app
4. Open Edge → `outlook.office.com` → sign in → Settings → Install this site as an app
5. In VSCode: set font family to `AdwaitaMono Nerd Font Mono` after Settings Sync runs

## Structure

```
dotfiles/
├── install.sh              # main entry point
├── zshrc
├── dots/
│   ├── gitconfig
│   └── gitignore.global
├── shell/
│   ├── aliases.sh
│   ├── path.sh
│   └── funcs.sh
├── vim/
│   ├── vimrc
│   └── install.sh
├── kitty/
│   └── kitty.conf
├── starship/
│   └── starship.toml
├── vscode/
│   └── settings.json       # reference copy — managed by VSCode Settings Sync
├── resources/
│   └── fonts/
│       └── adwaitamonoNF/  # AdwaitaMono Nerd Font Mono (SIL OFL)
└── packages/
    └── install.sh
```

## AWS credentials

Configure manually after install:

```bash
aws configure
```
