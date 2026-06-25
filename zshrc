source ~/dotfiles/shell/path.sh
source ~/dotfiles/shell/aliases.sh
source ~/dotfiles/shell/funcs.sh
source ~/dotfiles/shell/nvm.sh

export GPG_TTY=$(tty)

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

eval "$(starship init zsh)"

# Claude Code account switching
alias claude-personal='CLAUDE_CONFIG_DIR=~/.claude-personal claude'
alias claude-work='CLAUDE_CONFIG_DIR=~/.claude-work claude'
eval "$(direnv hook zsh)"
