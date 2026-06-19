# Fedora Dotfiles

Year of the linux desktop? Fedora Workstation dev box so I can get rid of WSL from my big machine. All the useful stuff from my old mac dotfiles with updates for the new OS.

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

**Packages (DNF)**
- Zsh + Starship prompt
- Kitty terminal
- Vim, tree, bat, unzip
- GitHub CLI (`gh`)
- htop, pavucontrol
- VSCode (Microsoft RPM repo)
- Microsoft Edge (for Teams and Outlook PWAs)
- DBeaver Community
- GNOME Tweaks
- .NET SDK 8.0
- EasyEffects
- podman-docker + podman-compose (Docker CLI emulation via Podman)
- VLC + media codecs (via RPM Fusion)
- Bruno API client (via GitHub RPM)
- libheif-freeworld + libheif-tools (HEIC image conversion)

**Shell scripts (`~/.local/bin`)**
- `heic2jpg` — batch convert HEIC photos to JPEG at quality 92 (`heic2jpg [directory]`)

**Via Flatpak**
- Bitwarden
- Slack
- Spotify

**Via install scripts**
- NVM + Node.js LTS
- AWS CLI + Session Manager plugin

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
├── scripts/
│   └── heic2jpg            # HEIC → JPG batch converter
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
├── containers/
│   └── containers.conf     # suppress podman compose provider warning
├── audio/
│   ├── audio-defaults.desktop  # autostart: default mic + mute camera audio
│   └── easyeffects/
│       └── input/
│           └── fedora-ugreen-usb.json  # mic processing preset
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

## Gotchas

**Teams PWA camera not working**
Edge may overwrite the Teams `.desktop` file on update, removing the Pipewire flag needed for camera access on Wayland. If the camera stops working, add `--enable-features=WebRTCPipeWireCapturer` to the Exec line in `~/.local/share/applications/msedge-ompifgpmddkgmclendfeacglnodjjndh-Default.desktop`.
