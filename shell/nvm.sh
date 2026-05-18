export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Automatically switches Node version on directory change.
#
# Priority order:
#   1. .nvmrc in the current directory or any parent — installed and activated if found
#   2. engines.node in the nearest package.json — first version number extracted from
#      the semver range (e.g. ">=22.0.0" → 22) and used if no .nvmrc is present
#   3. nvm default — restored when neither a .nvmrc nor an engines.node spec is found
autoload -U add-zsh-hook
load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  else
    local engines_version="" dir="$PWD"
    while [[ "$dir" != "/" ]]; do
      if [[ -f "$dir/package.json" ]]; then
        engines_version=$(PKG="$dir/package.json" node -e "try{const p=JSON.parse(require('fs').readFileSync(process.env.PKG,'utf8'));const m=((p.engines||{}).node||'').match(/\d+/);if(m)console.log(m[0])}catch(e){}" 2>/dev/null)
        break
      fi
      dir="$(dirname "$dir")"
    done

    if [[ -n "$engines_version" ]]; then
      local target
      target=$(nvm version "$engines_version" 2>/dev/null)
      if [[ "$target" == "N/A" ]]; then
        nvm install "$engines_version"
      elif [[ "$target" != "$(nvm version)" ]]; then
        nvm use "$engines_version"
      fi
    elif [ "$(nvm version)" != "$(nvm version default)" ]; then
      nvm use default
    fi
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
